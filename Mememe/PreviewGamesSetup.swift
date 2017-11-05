//
//  PreviewGamesSetup.swift
//  Mememe
//
//  Created by Duy Le on 11/4/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

extension PreviousGamesViewController{
    func setupSections(timeArr: [Int], currentTimeInt: Int){
        self.sections.append(PreviewSection(sectionTitle: "In 24 hours", fromInt: currentTimeInt, toInt: timeArr[0]))
        self.sections.append(PreviewSection(sectionTitle: "This week", fromInt: timeArr[0], toInt: timeArr[1]))
        self.sections.append(PreviewSection(sectionTitle: "Two Weeks Ago", fromInt: timeArr[1], toInt: timeArr[2]))
        self.sections.append(PreviewSection(sectionTitle: "Three Weeks Ago", fromInt: timeArr[2], toInt: timeArr[3]))
        self.sections.append(PreviewSection(sectionTitle: "A Month Ago", fromInt: timeArr[3], toInt: timeArr[4]))
        self.sections.append(PreviewSection(sectionTitle: "Two Months Ago", fromInt: timeArr[4], toInt: timeArr[5]))
        self.sections.append(PreviewSection(sectionTitle: "Three Months Ago", fromInt: timeArr[5], toInt: timeArr[6]))
        self.sections.append(PreviewSection(sectionTitle: "Four Months Ago", fromInt: timeArr[6], toInt: timeArr[7]))
        self.sections.append(PreviewSection(sectionTitle: "Five Months Ago", fromInt: timeArr[7], toInt: timeArr[8]))
        self.sections.append(PreviewSection(sectionTitle: "Six Months Ago", fromInt: timeArr[8], toInt: timeArr[9]))
        self.sections.append(PreviewSection(sectionTitle: "Seven Months Ago", fromInt: timeArr[9], toInt: timeArr[10]))
        self.sections.append(PreviewSection(sectionTitle: "Eight Months Ago", fromInt: timeArr[10], toInt: timeArr[11]))
        self.sections.append(PreviewSection(sectionTitle: "Nine Months Ago", fromInt: timeArr[11], toInt: timeArr[12]))
        self.sections.append(PreviewSection(sectionTitle: "Ten Months Ago", fromInt: timeArr[12], toInt: timeArr[13]))
        self.sections.append(PreviewSection(sectionTitle: "Eleven Months Ago", fromInt: timeArr[13], toInt: timeArr[14]))
        self.sections.append(PreviewSection(sectionTitle: "Last Year", fromInt: timeArr[14], toInt: timeArr[15]))
    }
}
