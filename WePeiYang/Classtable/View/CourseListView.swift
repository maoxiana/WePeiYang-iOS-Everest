//
//  CourseListView.swift
//  WePeiYang
//
//  Created by Halcao on 2017/11/22.
//  Copyright © 2017年 twtstudio. All rights reserved.
//

import UIKit

fileprivate struct C {
    static let cellWidth: CGFloat = 47
    static let cellHeight: CGFloat = 55
    static let dayCount = 7
    static let courseCount = 12
    
    static let classNumberViewWidth: CGFloat = 50
    static let dayNumberViewHeight: CGFloat = 30
}

protocol CourseListViewDelegate {
    /// 选中课程
    ///
    /// - Parameters:
    ///   - listView: 所在的 listView
    ///   - course: 被选中的课程
    func listView(_ listView: CourseListView, didSelectCourse course: ClassModel)
}

protocol CourseListViewDataSource {
    func days() -> [Int]
    func courses(in day: Int) -> [ClassModel]
}
//Hiererachy
//"CourseListView" UIView
//    +--- "containerView" UIView
//        +-- "scrollView" UIScrollView
//            +-- "contentView" UIView
//                +-- Subview 1 UIView
//                    +-- Subview 2 UIView
//                        +-- Subview 3 UIView
class CourseListView: UIView {
    // C stands for Constant
    
    var classNumberView: UIView!
    var dayNumberView: UIView!
    var updownContentView: UIScrollView!
    var tableViews: [UITableView] = []
    
    var delegate: CourseListViewDelegate?
    var dataSource: CourseListViewDataSource? {
        didSet {
            self.reloadData()
        }
    }
    
    var days: [Int] = []
    var coursesForDay: [Int : [ClassModel]] = [:]
    
    var week: [[ClassModel]] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        classNumberView = UIView(frame: .zero)
        dayNumberView = UIView(frame: .zero)
        updownContentView = UIScrollView(frame: .zero)
        updownContentView.showsVerticalScrollIndicator = false
        // updownContentView.delaysContentTouches = false
//        updownContentView.delaysContentTouches = false
//        updownContentView.panGestureRecognizer.delaysTouchesBegan = true
//        updownContentView.
        
        self.addSubview(dayNumberView)
        
//        updownContentView.contentSize = CGSize(width: self.width, height: CGFloat(C.courseCount) * C.cellHeight)
        
        dayNumberView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(C.dayNumberViewHeight)
        }
        
        let dayArray = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
        // 一般是有七天
        var dayNumberLabels: [UILabel] = []
        for i in 0..<C.dayCount {
            let label = UILabel(frame: .zero)
            label.text = dayArray[i]
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 13)
            label.textColor = .lightGray
            dayNumberView.addSubview(label)
            label.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.height.equalToSuperview()
                make.width.equalTo(C.cellWidth)
                if i == 0 {
                    make.left.equalToSuperview().offset(C.cellWidth)
                } else {
                    make.left.equalTo(dayNumberLabels[i-1].snp.right)
                }
            }
            dayNumberLabels.append(label)
        }

        
        let containerView = UIView()
        self.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.top.equalTo(dayNumberView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        containerView.addSubview(updownContentView)
        updownContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let contentView = UIView()
        updownContentView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(classNumberView)
        classNumberView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(C.classNumberViewWidth)
            make.height.equalTo(CGFloat(C.courseCount) * C.cellHeight)
        }
        
        var courseCountLabels: [UILabel] = []
        for i in 0..<C.courseCount {
            let label = UILabel(frame: .zero)
            label.text = "\(i+1)"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .lightGray
            classNumberView.addSubview(label)
            label.snp.makeConstraints { make in
                make.height.equalTo(C.cellHeight)
                make.width.equalTo(C.cellWidth)
                make.left.equalToSuperview()
                if i == 0 {
                    make.top.equalToSuperview().offset(C.cellHeight)
                } else {
                    make.top.equalTo(courseCountLabels[i-1].snp.bottom)
                }
            }
            courseCountLabels.append(label)
        }
        courseCountLabels.last!.snp.makeConstraints { make in
            make.bottom.equalTo(classNumberView.snp.bottom)
        }
        
        for i in 0..<7 {
            let tableView = UITableView()
            tableViews.append(tableView)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .none
            tableView.tag = i+1
            contentView.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.top.equalTo(courseCountLabels[0].snp.top)
                make.bottom.equalToSuperview()
                if i == 0 {
                    make.left.equalToSuperview().offset(C.cellWidth)
                } else {
                    make.left.equalTo(tableViews[i-1].snp.right)
                }
                make.height.equalTo(CGFloat(C.courseCount) * C.cellHeight)
                make.width.equalTo(C.cellWidth)
            }
            tableView.isScrollEnabled = false
        }
        
//        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)];
//        [recognizer setNumberOfTapsRequired:1];
//        MYScrollView.userInteractionEnabled = YES;
//        [MYScrollView addGestureRecognizer:recognizer];
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewTouch(sender:)))
        updownContentView.addGestureRecognizer(recognizer)
    }
    
    func tableViewTouch(sender: UITapGestureRecognizer) {
        let location = sender.location(in: tableViews[0])
        let index = Int(location.x / C.cellWidth)
        let realLocation = sender.location(in: tableViews[index])
        let indexPath = tableViews[index].indexPathForRow(at: realLocation)
        if let indexPath = indexPath, let model = coursesForDay[index+1]?[indexPath.row] {
            self.delegate?.listView(self, didSelectCourse: model)
            print(model.courseName)
        }
        // tableViews[0].
    }
    
    func reloadData() {
        guard let dataSource = dataSource else {
            return
        }
        
        days = dataSource.days()
        days.forEach { day in
            coursesForDay[day] = dataSource.courses(in: day)
        }
        
        for key in coursesForDay.keys {
            coursesForDay[key]?.sort(by: { a, b in
                return a.arrange[0].start < b.arrange[0].start
            })
            var lastEnd = 0
            for course in coursesForDay[key]! {
                if (course.arrange[0].start-1) - (lastEnd+1) >= 0 {
                    let placeholder = ClassModel(JSONString: "{\"arrange\": [{\"day\": \"\(course.arrange[0].day)\", \"start\":\"\(lastEnd+1)\", \"end\":\"\(course.arrange[0].start-1)\"}]}")!
                    // placeholders[i].append(placeholder)
                    coursesForDay[key]?.append(placeholder)
//                    item.append(placeholder)
                }
                lastEnd = course.arrange[0].end
            }
            coursesForDay[key]?.sort(by: { $0.0.arrange[0].start < $0.1.arrange[0].start })
        }
        
        
        self.tableViews.forEach({ $0.reloadData() })
    }
}

extension CourseListView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let courses = coursesForDay[tableView.tag]
        return courses?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = coursesForDay[tableView.tag]?[indexPath.row]
        let cell = CourseCell(style: .default, reuseIdentifier: "reuse")
        cell.load(course: model!)
        return cell
    }
}

extension CourseListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = coursesForDay[tableView.tag]?[indexPath.row]
        return CGFloat(model!.arrange[0].length) * C.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let model = coursesForDay[tableView.tag]?[indexPath.row] {
            self.delegate?.listView(self, didSelectCourse: model)
            print(model.courseName)
        }
    }
}