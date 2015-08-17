//
//  ViewController.swift
//  SQLiteTest--001
//
//  Created by FelixYin on 15/7/31.
//  Copyright © 2015年 felixios. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
       
        self.insertManyPerson1()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //向数据库中添加一个记录
    
   private func insertPerson () ->Void {
    
       let p = Person(dict: ["name":"张哥","age":23,"address":"北京市海淀区"])
        
        //将数据添加到数据库表中
        
       let result =  p.insertPerson()
        
        
        print(result)
    
    
    }
    
    //使用事物和预编译（sqlite3_preparev2）插入多条记录
    
    private func insertManyPerson1() ->Void {
    
       let manager = SQLiteManager.sharedManager
        
        
        //这个执行最快的原因是：使用了事物，与预编译sql
        
        //预编译sql可以先把sql准备好，最后只需要绑定参数...再执行sql，效率就提升上来了
        
        //计算执行时间 (执行时间为0.105秒)  最快的
        
       //开始事物
        
       let start = CFAbsoluteTimeGetCurrent()
        
       manager.beginTransaction()
        
       let sql = "insert into T_Person (name,age,address) values(?,?,?)"
        
        
        for i in 0..<5000{
        
            manager.pasementInsertManyRecord(sql, params: "ZhangZhang\(i+100)",i+100,"北京----\(i+100)")
        
        
        }
        
        
      //提交事物
        
      manager.commitTransaction()
        
        
      print("预编译，事务---》\(CFAbsoluteTimeGetCurrent() - start)")
    
    
    }
    
    //向数据库中添加多条记录(使用事物)
    
    private func insertManyPerson2 () ->Void {
        
       //这种方式快速的原因是：
        
        //显示的开启事物，所以需要显示的提交事物，开启事物，提交事物也只有一次
       
       let manager = SQLiteManager.sharedManager
        
       
        //开始事物
       manager.beginTransaction()
        
        
        
       //计算执行时间 (执行时间为0.25秒)
        
       let start = CFAbsoluteTimeGetCurrent()
       
        for i in 0..<5000{
        
            let p = Person(dict: ["name":"eeee\(i+1)","age":32+i,"address":"BeiJing\(i)"])
            
            p.insertPerson()
            
            
//            if i == 200 {
//            
//              //模拟突然情况，事物回滚
//                
//              manager.rollBackTransaction()
            
//              break
//
//            }
        
        
        }
        
        
        print(CFAbsoluteTimeGetCurrent() - start)
    
    
       //提交事物
        manager.commitTransaction()
    
    
    }
    
    
//  使用最简单的方式插入数据
    
    
    private func insertPersons() -> Void {
        
        //简单的方式插入数据插入数据慢的原因是：
        //当插入数据时，这种方式会默认开启一个事物，插入成功后提交事物，也就是每插入一条记录都会创建一个新的事物，也会相应的提交多次，所以性能受到极大的影响
    
       
        //这样需要3.17秒
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for i in 0..<5000 {
        
            let p = Person(dict: ["name":"KKK\(i+10000)","age":23,"address":"安徽\(i)"])
            
            p.insertPerson()
        
        }
    
        print("最简单的方式插入多条记录:\(CFAbsoluteTimeGetCurrent() - start)")
    
    
    
    }
    
    
    
    //更新一条记录
    
    private func updatePserson () -> Void {
    
      let p = Person (dict: ["name":"张7777哥","age":23,"address":"北京市朝阳区111","id": 3])
        
        
      let result = p.updatePerson()
        
        
      print(result)
    
    
    
    }
    
    
    //删除一条记录
    
    
    private func deletePerson () -> Void {
    
    let p = Person (dict: ["name":"张77哥","age":23,"address":"北京市","id": 3])
        
    let result = p.deletePerson()
    
        
    print(result)
    
    }

    
    //查询数据中所有的记录
    
    private func selectRecord () ->Void {
    
    
//    let p = Person(dict: ["name":"张77哥","age":23,"address":"北京市","id": 3])
        
      let persons = Person.selectRecord()
        
        if let p = persons {
        
            for dict in p {
            
               let person = Person(dict: dict)
                
                
               print(person)
            
            }
        
        }
    
    
    }

}

