//
//  VoiceLogParser.swift
//  LazyReef
//
//  Pure parser for voice transcriptions describing water parameter readings.
//  No UI dependency — easy to unit test.
//

import Foundation

/// Result of parsing one keyword + number pair in an utterance.
struct ParsedReading: Hashable {
    let parameter: WaterParameterType
    let value: Double
    /// Original substring that matched, for preview/highlighting.
    let raw: String
}

enum VoiceLogParser {

    /// Parse a transcription into one or more parameter readings.
    /// Supports multi-reading utterances: "magie 450 canxi 420" → 2 readings.
    /// Recognizes ASCII digits, Vietnamese spoken digits ("bốn năm không" → 450),
    /// compound Vietnamese numbers ("một ngàn ba trăm" → 1300), and decimals
    /// ("tám chấm hai" → 8.2). Ambiguous parses are resolved using
    /// `plausibleRange(for:)`.
    static func parse(_ text: String) -> [ParsedReading] {
        let normalized = normalize(text)
        let tokens = tokenize(normalized)
        guard !tokens.isEmpty else { return [] }

        var results: [ParsedReading] = []
        var i = 0
        while i < tokens.count {
            if let parameter = keywordMap[tokens[i]] {
                if let (value, consumed) = readNumber(from: i + 1,
                                                     tokens: tokens,
                                                     parameter: parameter) {
                    let raw = tokens[i..<min(i + 1 + consumed, tokens.count)]
                        .joined(separator: " ")
                    results.append(ParsedReading(parameter: parameter,
                                                 value: value,
                                                 raw: raw))
                    i += 1 + consumed
                    continue
                }
            }
            i += 1
        }
        return results
    }

    /// Plausible range allowed for a parameter — wider than `idealRange`, used
    /// both as a sanity check for manual entry and to disambiguate voice parses.
    static func plausibleRange(for type: WaterParameterType) -> ClosedRange<Double> {
        switch type {
        case .temperature: return 15...35
        case .ph: return 5...10
        case .salinity: return 1.000...1.040
        case .kh: return 1...20
        case .ca: return 200...600
        case .mg: return 800...2000
        case .no3: return 0...100
        case .po4: return 0.001...1.0
        case .co2: return 0...20
        case .oxygen: return 2...12
        }
    }

    // MARK: - Internals

    private static let keywordMap: [String: WaterParameterType] = [
        // Mg
        "mg": .mg, "magie": .mg, "magiee": .mg, "magnesium": .mg, "magnesi": .mg,
        // Ca
        "ca": .ca, "canxi": .ca, "calcium": .ca, "can": .ca,
        // KH
        "kh": .kh, "alkalinity": .kh, "kabonat": .kh,
        // pH
        "ph": .ph, "pehat": .ph,
        // NO3
        "no3": .no3, "nitrat": .no3, "nitrate": .no3, "nito": .no3,
        // PO4
        "po4": .po4, "photphat": .po4, "phosphate": .po4, "phot": .po4,
        // Temperature
        "temp": .temperature, "temperature": .temperature,
        "nhietdo": .temperature, "nhiet": .temperature,
        // Salinity
        "doman": .salinity, "salinity": .salinity, "man": .salinity,
        // CO2
        "co2": .co2, "cacbonic": .co2, "cacbon": .co2,
        // Oxygen
        "o2": .oxygen, "oxy": .oxygen, "oxygen": .oxygen, "oxi": .oxygen
    ]

    private static let vietnameseDigits: [String: Int] = [
        "khong": 0, "linh": 0, "le": 0,
        "mot": 1, "moot": 1,
        "hai": 2,
        "ba": 3,
        "bon": 4, "tu": 4,
        "nam": 5, "lam": 5, "lan": 5,
        "sau": 6,
        "bay": 7,
        "tam": 8,
        "chin": 9
    ]

    private static let magnitudes: [String: Int] = [
        "muoi": 10, "chuc": 10,
        "tram": 100,
        "nghin": 1000, "ngan": 1000,
        "trieu": 1_000_000
    ]

    private static let decimalSeparators: Set<String> = ["cham", "phay", "."]

    private static func digitValue(_ token: String) -> Int? {
        if token.count == 1, let v = Int(token), v >= 0, v <= 9 {
            return v
        }
        return vietnameseDigits[token]
    }

    private static func isNumberToken(_ token: String) -> Bool {
        if Double(token) != nil { return true }
        if vietnameseDigits[token] != nil { return true }
        if magnitudes[token] != nil { return true }
        if decimalSeparators.contains(token) { return true }
        return false
    }

    /// Strip Vietnamese diacritics, lowercase, and merge known multi-word keywords.
    private static func normalize(_ text: String) -> String {
        var folded = text
            .folding(options: .diacriticInsensitive, locale: Locale(identifier: "vi_VN"))
            .lowercased()
        // Merge multi-word keywords/phrases that should be single tokens.
        let merges: [(String, String)] = [
            ("nhiet do", "nhietdo"),
            ("do man", "doman"),
            ("nong do", "nongdo"),
            ("phot phat", "photphat"),
            ("ni tro", "nito"),
            ("ni trat", "nitrat"),
            ("cac bon", "cacbon"),
            ("cac bonic", "cacbonic")
        ]
        for (from, to) in merges {
            folded = folded.replacingOccurrences(of: from, with: to)
        }
        return folded
    }

    /// Tokenize on whitespace + non-decimal punctuation.
    /// Keeps "cham"/"phay" as distinct tokens so the number parser can use them.
    private static func tokenize(_ text: String) -> [String] {
        let separators = CharacterSet.whitespacesAndNewlines
            .union(CharacterSet(charactersIn: ":;!?()[]{}/\\"))
        let raw = text
            .components(separatedBy: separators)
            .filter { !$0.isEmpty }
        return raw.map { token -> String in
            if token.first?.isNumber == true {
                // Normalize comma decimal "8,2" → "8.2"
                return token.replacingOccurrences(of: ",", with: ".")
            }
            return token.trimmingCharacters(in: CharacterSet(charactersIn: ".,"))
        }
    }

    // MARK: - Number reading

    /// Read a number expression starting at `start`. Tries multiple interpretations
    /// and prefers one inside `plausibleRange(for: parameter)`.
    private static func readNumber(from start: Int,
                                   tokens: [String],
                                   parameter: WaterParameterType) -> (Double, Int)? {
        guard start < tokens.count else { return nil }

        // Fast path: a single ASCII numeric token like "8.2" — but only if
        // no further number-like tokens follow. Otherwise SFSpeechRecognizer
        // splits like "450" → "4 5 0" or "4 trăm năm mươi" would truncate
        // to just 4. In that case fall through to run-based parsing.
        if let v = Double(tokens[start]) {
            let nextIsNumber = start + 1 < tokens.count && isNumberToken(tokens[start + 1])
            if !nextIsNumber {
                return (v, 1)
            }
        }

        // Collect the contiguous run of number-like tokens.
        var end = start
        while end < tokens.count, isNumberToken(tokens[end]) {
            end += 1
        }
        guard end > start else { return nil }
        let run = Array(tokens[start..<end])

        var candidates: [Double] = []
        if let v = parseCompoundVietnameseNumber(run) { candidates.append(v) }
        if let v = parseDigitConcatenation(run) {
            if !candidates.contains(v) { candidates.append(v) }
        }

        guard !candidates.isEmpty else { return nil }

        // Prefer a candidate inside the plausible range for this parameter.
        let plausible = plausibleRange(for: parameter)
        if let best = candidates.first(where: { plausible.contains($0) }) {
            return (best, run.count)
        }
        return (candidates[0], run.count)
    }

    /// Compound Vietnamese number: handles "ngàn / trăm / mươi" multipliers,
    /// trailing single digits, and optional decimal tail.
    ///   "một ngàn ba trăm năm mươi" → 1350
    ///   "ba mươi lăm"               → 35
    ///   "mười"                       → 10
    ///   "tám chấm hai"               → 8.2
    static func parseCompoundVietnameseNumber(_ tokens: [String]) -> Double? {
        var total = 0
        var pending = 0
        var inDecimal = false
        var fracDigits = ""
        var consumedAnything = false

        for token in tokens {
            if decimalSeparators.contains(token) {
                total += pending
                pending = 0
                inDecimal = true
                consumedAnything = true
                continue
            }

            if let mag = magnitudes[token] {
                if inDecimal { break } // magnitudes don't apply inside fraction
                if mag == 10, pending == 0, total == 0 {
                    total = 10
                } else if pending == 0 {
                    // stray magnitude — ignore but don't break
                } else {
                    total += pending * mag
                    pending = 0
                }
                consumedAnything = true
                continue
            }

            if let d = digitValue(token) {
                if inDecimal {
                    fracDigits += String(d)
                } else {
                    // Commit any previous pending digit as "ones".
                    total += pending
                    pending = d
                }
                consumedAnything = true
                continue
            }

            break
        }

        guard consumedAnything else { return nil }

        var value = Double(total + pending)
        if !fracDigits.isEmpty, let frac = Double("0.\(fracDigits)") {
            value += frac
        }
        return value
    }

    /// Digit-by-digit concatenation:
    ///   "bốn năm không" → "450" → 450
    ///   "tám chấm hai"  → "8.2"
    /// Skips magnitude words so phrases like "bốn năm không" parse cleanly even
    /// if a stray magnitude is intermixed.
    static func parseDigitConcatenation(_ tokens: [String]) -> Double? {
        var intStr = ""
        var fracStr = ""
        var inDecimal = false
        var consumedAnything = false

        for token in tokens {
            if decimalSeparators.contains(token) {
                inDecimal = true
                consumedAnything = true
                continue
            }
            if let d = digitValue(token) {
                if inDecimal {
                    fracStr += String(d)
                } else {
                    intStr += String(d)
                }
                consumedAnything = true
                continue
            }
            // Skip magnitudes in concat mode.
            if magnitudes[token] != nil { continue }
            break
        }

        guard consumedAnything else { return nil }
        let s = (intStr.isEmpty ? "0" : intStr) + (fracStr.isEmpty ? "" : ".\(fracStr)")
        return Double(s)
    }
}
