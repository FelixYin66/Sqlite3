//
//  Person.swift
//  SQLiteTest--001
//
//  Created by FelixYin on 15/8/1.
//  Copyright © 2015年 felixios. All rights reserved.
//

import UIKit

class Person: NSObject {
    
    var id:Int = 0
    
    var name:String?
    
    var age:Int = 0
    
    var address:String?
    
    init(dict:[String:AnyObject]) {
        
        super.init()
        
        setValuesForKeysWithDictionary(dict)
        
    }
    
    
//    打印描述
    
    
    private static let pro = ["id","name","age","address"]
    
    override var description: String {
    
    
      return "\(dictionaryWithValuesForKeys(Person.pro))"
    }
    
    
    
    
    
//    插入模型到数据库中
    
    func insertPerson () -> Bool {
        
        
     assert(address != nil && name != nil, "名字，地址都不能为空")
    
      //sql语句，中间拼接的值要在单引号的里面，单引号不能省去
        
      let sql = "INSERT INTO T_Person (name,age,address) VALUES ('\(name!)',\(age),'\(address!)');"
        
      
      //执行sql语句
        
     let result = SQLiteManager.sharedManager.execSQL(sql)
        

     //返回执行结果
        
     return result
    
    }
    
    
//    更新数据库中的记录
    
    
    func updatePerson() -> Bool {
    
    let sql = "update T_Person set\n" +
        
        "name = '\(name!)',\n" +
        
        "age = \(age),\n" +
        
        "address = '\(address!)'\n" +
        
        "where id = \(id);"
    
       
    //执行sql
        
   let result = SQLiteManager.sharedManager.execSQL(sql)
        
        
   return result
        
    }
    
    
//  删除一条记录
    
    
    func deletePerson () -> Bool {
    
        let sql = "DELETE FROM T_Person Where id = \(id);"
        
        
        let result = SQLiteManager.sharedManager.execSQL(sql)
    
        
        return result
    
    }
    
    
    
//  查询数据库中的数据
    
    
    class func selectRecord() -> [[String:AnyObject]]? {
        
       let sql = "SELECT NAME,AGE,ADDRESS,ID FROM T_Person"
    
    
      return SQLiteManager.sharedManager.selectRecord(sql)
    
    }

}
