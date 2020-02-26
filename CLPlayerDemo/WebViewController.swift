//
//  WebViewController.swift
//  CLPlayerDemo
//
//  Created by 刘永和 on 2019/12/11.
//  Copyright © 2019 JmoVxia. All rights reserved.
//

import UIKit
import  SafariServices
class WebViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    var webModels:Array = Array<Any>.init();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "网页"
        tableview.dataSource = self;
        tableview.delegate = self;
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "增加", style: .done, target: self, action: #selector(addCell))
        webModels.append(WebModel(name: "谷歌", url: "https://www.google.com"))
        // Do any additional setup after loading the view.
        
    }

    @objc func addCell() {
        print("增加")
        testTextFieldAlert(isReplace:false)
    }
    
    func testTextFieldAlert(name:String="",url:String="",index:Int = 0,isReplace:Bool=true){
        let alertController = UIAlertController(title: "输入名称和URL", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "网址名称"
            textField.text = name
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "网址URL"
            textField.text = url
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
            let nameTextField = alertController.textFields![0]
            let urlTextField = alertController.textFields![1]
            let newModel = WebModel(name: nameTextField.text!, url: urlTextField.text!)
            if isReplace{
                self.webModels[index] = newModel
            }else{
                self.webModels.append(newModel)
            }
            self.tableview.reloadData()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }

    func gotoWeb(url:String) {
        let url = URL(string: url)

        let sf = SFSafariViewController(url: url!)
        
        present(sf, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension WebViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return webModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellid = "testCellID"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellid)
        if cell==nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellid)
        }
        let model:WebModel = webModels[indexPath.row] as! WebModel
        cell?.textLabel?.text = model.name
        return cell!
    }
    //MARK: UITableViewDelegate
    // 设置cell高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    // 选中cell后执行此方法
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let model:WebModel = webModels[indexPath.row] as! WebModel
        gotoWeb(url: model.url)
    }

    //设置动作按钮的函数
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
         //添加删除按钮
        let deleteRowAction:UITableViewRowAction = UITableViewRowAction(style:.destructive, title: "删除"){
            (action, index) in
            //先从数据源那里删除数据
            self.webModels.remove(at: index.row)
            //然后在把tableview上的指定行删除
            self.tableview.deleteRows(at: [index], with: .automatic);
            
        }
        let editRowAction:UITableViewRowAction = UITableViewRowAction(style: .normal, title: "编辑") { (action, index) in
            let model:WebModel = self.webModels[index.row] as! WebModel
            self.testTextFieldAlert(name: model.name, url: model.url,index: index.row)
        }
        
        let actions = [editRowAction,deleteRowAction];
        return actions;
    }

}
