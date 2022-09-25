//
// Created by osushi on 2022/09/23.
//

import Foundation

protocol Parser {
    func parse(rawAllString: String) throws -> [DisplayEvent]
}

struct ScriptParser: Parser {
    func validate(rawText: String) -> Bool {
        do {
            let _ = try parse(rawAllString: rawText)
            return true
        } catch {
            return false
        }
    }

    func parse(rawAllString raw: String) throws -> [DisplayEvent] {
        var rawAllString = raw
        rawAllString.removeAll(where: { $0 == "\n" })

        do {
            guard rawAllString.countChar(char: "[" ) == rawAllString.countChar(char: "]") else {
                throw ParseError.invalidBracketsPair(message: "brackets pair broken")
            }

            guard rawAllString.contains("[e]") else { throw ParseError.notFoundEndTag }

            let events = try rawAllString.components(separatedBy: "[")
                                         .filter { !$0.isEmpty }
                                         .map { (raw: $0, isCommandInclude: $0.contains("]")) }
                                         .map { $0.isCommandInclude ? try splitCommandIncludingText(raw: $0.raw) : stringToCharacter(string: $0.raw) }
                                         .flatMap { $0 }

            return events
        } catch {
            throw error
        }
    }

    //  cm] or cm]text

    private func splitCommandIncludingText(raw: String) throws -> [DisplayEvent] {
        var result: [DisplayEvent] = []
        let commandAndText = raw.components(separatedBy: "]")

        do {
            try result.append(DisplayEvent.parseCommand(rawCommand: commandAndText.first!))
        } catch {
            throw error
        }

        if let text = commandAndText.last, !text.isEmpty {
            result += stringToCharacter(string: text)
        }

        return result
    }

    private func stringToCharacter(string: String) -> [DisplayEvent] {
        string.map { c in DisplayEvent.character(char: c) }
    }
}

private extension String {
    func countChar(char: Character) -> Int {
        return filter({ $0 == char }).count
    }
}