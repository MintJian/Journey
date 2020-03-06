//
//  QuestionData.swift
//  PersonalityQuiz
//
//  Created by Dearest on 2020/03/06.
//  Copyright © 2020 Dearest. All rights reserved.
//

import Foundation

struct Question {
    var text: String
    var type: ResponseType
    var answers: [Answer]
}

enum ResponseType {
    case single, multiple, ranged
}

struct Answer {
    var text: String
    var type: AnimalType
    
}

enum AnimalType: Character{
    case dog = "🐶", cat = "🐱", rabbit = "🐰", turtle = "🐢"
    
    var defination: String {
        switch self {
            case .dog:
                return "您真是外向。 您与自己所爱的人在一起，并与朋友一起享受活动。"
            case .cat:
                return "调皮，但脾气暴躁，您喜欢按照自己的意愿做事。"
            case .rabbit:
                return "您喜欢所有柔软的东西。 您健康且充满活力。"
            case .turtle:
                return "您的智慧超越了您的岁月，并且专注于细节。 踏实和稳重是赢得比赛的关键。"
        }
    }
}

var questions: [Question] = [
    Question(text: "你最喜欢下面的哪个食物?",
             type:.single,
             answers: [
                Answer(text: "牛排", type: .dog),
                Answer(text: "鱼", type: .cat),
                Answer(text: "胡萝卜", type: .rabbit),
                Answer(text: "玉米", type: .turtle)
                      ]),
    Question(text: "你最喜欢下面的哪些活动?",
             type: .multiple,
             answers: [
                Answer(text: "游泳", type: .turtle),
                Answer(text: "睡觉", type: .cat),
                Answer(text: "拥抱", type: .rabbit),
                Answer(text: "吃东西", type: .dog)
                      ]),
    
    Question(text: "你有多喜欢坐车?",
             type: .ranged,
             answers: [
                Answer(text: "我不喜欢", type: .cat),
                Answer(text: "我有点紧张",
                      type: .rabbit),
                Answer(text: "我几乎不会在意",
                      type: .turtle),
                Answer(text: "我十分喜欢", type: .dog)
                     ])
]
