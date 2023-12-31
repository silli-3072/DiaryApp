
import UIKit
import RealmSwift
import UserNotifications

class HomeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let realm = try! Realm()
    let buttonIcon = UIImage(systemName: "pencil.circle", withConfiguration: .none)
    
    var timeOfDay: String = ""
    var modifiedDateCount: Int = 0
    var morningSentence: String = ""
    var nightSentence: String = ""
    
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var addMorningButton: UIButton!
    @IBOutlet var addNightButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                
            } else {
                
            }
        }
        
        morningScheduleNotification()
        nightScheduleNotification()
        
        let leftSwipeGesture = UISwipeGestureRecognizer(
            target: self,
            action: #selector(HomeViewController.getSwipe(_:))
        )
        
        leftSwipeGesture.direction = .left
        self.view.addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(
            target: self,
            action: #selector(HomeViewController.getSwipe(_:))
        )
        
        rightSwipeGesture.direction = .right
        self.view.addGestureRecognizer(rightSwipeGesture)
        
        addMorningButton.layer.cornerRadius = 30
        addMorningButton.setImage(buttonIcon, for: .normal)
        
        addNightButton.layer.cornerRadius = 30
        addNightButton.setImage(buttonIcon, for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    @IBAction func addMorningDiary() {
        timeOfDay = "morning"
        morningSentence = getMorningDiaryDate()
        
        transition(timeOfDay: timeOfDay,sentence: morningSentence)
        
    }
    
    @IBAction func addNightDiary() {
        timeOfDay = "night"
        nightSentence = getNightDiaryDate()
        
        transition(timeOfDay: timeOfDay, sentence: nightSentence)
        
    }
    
    @IBAction func addDay() {
        modifiedDateCount += 1
        
        updateUI()
    }
    
    @IBAction func subtractDay() {
        modifiedDateCount -= 1
        
        updateUI()
    }
    
    @objc func getSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            modifiedDateCount += 1
            updateUI()
        case .right:
            modifiedDateCount -= 1
            updateUI()
        default:
            break
        }
    }
    
    func getCurrentDate() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let date = NSDate()
        let modifiedDate = calendar.date(byAdding: .day, value: modifiedDateCount, to: date as Date)!
        return  modifiedDate as Date
    }
    
    func stringConversion(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        let dateStr = formatter.string(from: date as Date)
        formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale?
        return  dateStr
        
    }
    
    func getMorningDiaryDate() -> String{
        let morningDiary = realm.objects(DiaryData.self).filter("timeOfDay == 'morning'")
        let arrayCount = morningDiary.count
        
        if arrayCount == 0 {
            return morningSentence
        }
        
        for i in 0...arrayCount - 1 {
            let dayData = stringConversion(date: morningDiary[i].day)
            
            if dayLabel.text == dayData {
                morningSentence = morningDiary[i].sentence
                var editSentence = buttonWordCountCheck(sentence: morningSentence)
                addMorningButton.setTitle(editSentence, for: .normal)
                addMorningButton.setImage(nil, for: .normal)
                return morningSentence
            } else {
                addMorningButton.setTitle("", for: .normal)
                addMorningButton.setImage(buttonIcon, for: .normal)
            }
            
        }
        
        morningSentence = ""
        return morningSentence
    }
    
    func getNightDiaryDate() -> String{
        let nightDiary = realm.objects(DiaryData.self).filter("timeOfDay == 'night'")
        let arrayCount = nightDiary.count
        
        if arrayCount == 0 {
            return nightSentence
        }
        
        for i in 0...arrayCount - 1 {
            let dayData = stringConversion(date: nightDiary[i].day)
            
            if dayLabel.text == dayData {
                nightSentence = nightDiary[i].sentence
                var editSentence = buttonWordCountCheck(sentence: nightSentence)
                addNightButton.setTitle(editSentence, for: .normal)
                addNightButton.setImage(nil, for: .normal)
                return nightSentence
            } else {
                addNightButton.setTitle("", for: .normal)
                addNightButton.setImage(buttonIcon, for: .normal)
            }
            
        }
        
        nightSentence = ""
        return nightSentence
    }
    
    func morningScheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "おはようございます！"
        content.body = "朝の日記を書いてみませんか？"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "morningNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("通知のスケジュールに失敗しました：\(error.localizedDescription)")
            } else {
                print("通知が正常にスケジュールされました")
            }
        }
    }
    
    func nightScheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "1日お疲れ様でした"
        content.body = "夜の日記を書いてみませんか？"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "morningNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("通知のスケジュールに失敗しました：\(error.localizedDescription)")
            } else {
                print("通知が正常にスケジュールされました")
            }
        }
    }
    
    func buttonWordCountCheck(sentence: String) -> String{
        var sentence = sentence
        
        var wordCount = sentence.count
        
        if wordCount >= 130 {
            var eraseNumber = wordCount - 130
            sentence.removeLast(eraseNumber)
            sentence = sentence + "..."
            
            return sentence
        }
        
        return sentence
        
    }
    
    func updateUI() {
        let date = getCurrentDate()
        dayLabel.text = stringConversion(date: date)
        
        getMorningDiaryDate()
        getNightDiaryDate()
        
    }
    
    func transition(timeOfDay: String, sentence: String) {
        let storyboard: UIStoryboard = self.storyboard!
        let addDiaryVC = storyboard.instantiateViewController(withIdentifier: "AddDiary") as! UINavigationController
        addDiaryVC.modalPresentationStyle = .fullScreen
        let getAddDiaryVC = addDiaryVC.viewControllers[0] as! AddDiaryViewController
        getAddDiaryVC.dayData = dayLabel.text!
        getAddDiaryVC.timeOfDay = timeOfDay
        getAddDiaryVC.sentence = sentence
        self.present(addDiaryVC, animated: true, completion: nil)
    }
    
}
