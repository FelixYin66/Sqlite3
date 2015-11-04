//
//  SQLiteManager.swift
//  SQLiteTest--001
//
//  Created by FelixYin on 15/7/31.
//  Copyright © 2015年 felixios. All rights reserved.
//

import Foundation


class SQLiteManager: NSObject {
    
//    保存句柄变量  COpaquePointer
    
    private var cOpaque:COpaquePointer = nil   //不能使用？
    
//    提供一个全局的访问点（使用类成员属性）
    
    private static let instance = SQLiteManager()
    
    class var sharedManager:SQLiteManager {
    
    
      return instance
    }
    
//    打开数据库
    func openDB (dbName:String) ->Void {
    
        /*
        
        句柄介绍：
        句柄是一个东东的描述，他被定义为一个结构体，
        这个结构体可能会包含要描述的东东的具体信息，
        比如位置、大小、类型等等
        我们有了这个描述信息我们能去找到这个东东，然后操纵它
        
        
        
        
        sqlite3（句柄） 结构体就是被用来描述我们磁盘里的数据库文件的，有了这个描述符我们就可以对这个数据库进行各种操作了
        
        
        操作数据库的前提是：需要创建一个句柄
        
        sqlite 里面你要操纵数据库我们先得创建一个句柄，然后后面所有对数据库得操作都会用到这个句柄
        
        
        
        sqlite里最常用到的是sqlite3 *类型。从数据库打开开始，sqlite就要为这个类型准备好内存，
        
        直到数据库关闭，整个过程都需要用到这个类型。当数据库打开时开始，
        
        这个类型的变量就代表了你要操作的数据库，即句柄
        
        */
        
        //第一个参数是数据库在此盘中的路径    Int8 是一个c语言中的char   int8 byte
        
        //第二个参数是句柄地址   ppDb: UnsafeMutablePointer<COpaquePointer>  是一个句柄的指针  COpaquePointer
        
        //path 中的true代表展开波浪号   如果是false path的值是  ~/Documents/testDB.db 打开数据库失败
        
        let u = "/" + dbName
        
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!.stringByAppendingString(u)
        
        
        
        print(path)
        
        //将字符串转换成c字符数组
        
        let cStr = path.cStringUsingEncoding(NSUTF8StringEncoding)!
        
        
        //打开数据库 sqlite3_open打开数据库的时候，如果数据库不存在，就新创建一个
        let result = sqlite3_open(cStr, &cOpaque)
        
        
        if result != SQLITE_OK {
        
           print("数据库打开失败！")
            
           return
        
        }
//        ----------------------------------数据库打开成功，就立刻创建一张表-------------------------------
        
        print("数据库打开成功！")
        
        
//        创建一张表
        
       let execResult = createTable()
        
        if execResult {
        
            print("创表成功")
        
        }else{
        
        
           print("创表失败")
            
        }
     
    
    }
    

//    执行sql语句
    
    func execSQL (strSQL:String) -> Bool {
        
//      方便调试，这里输出sql语句
        
//        print(strSQL)

//    转换成c语言字符数组，由于sqlite使用的是c语言函数，使用的是一套c语法
        
     let cSQL = strSQL.cStringUsingEncoding(NSUTF8StringEncoding)!
    
    
//   执行函数
        
        
//        参数说明：第一个参数是：句柄  第二个参数是：cSQL语句  第三个是：回调函数  第四个是：回调函数参数  第五个是：错误信息
//        这些参数还得继续研究，不是特别明白
//        sqlite3_exec 可以执行任何sql
        
    let result = sqlite3_exec(cOpaque, cSQL, nil, nil, nil)
    
    
        //这样返回省去部分代码
           return result == SQLITE_OK
    }
    
//    开始事物
    
    func beginTransaction () ->Bool {
    
    
     return self.execSQL("BEGIN TRANSACTION")
    
    }
    
    
//    提交事物
    
    func commitTransaction () ->Bool {
    
    
    
     return self.execSQL("COMMIT TRANSACTION")
    }
    
    
//    事务回滚
    
    
    func rollBackTransaction () ->Bool {
    
    
    
      return self.execSQL("ROLLBACK TRANSACTION")
    }
    
    
    // 预编译插入多条记录,CVarArgType可以保存多个参数值  NSLog可以给出提醒
    
    
    /**
    typedef void (*sqlite3_destructor_type)(void*);
    #define SQLITE_STATIC      ((sqlite3_destructor_type)0)
    #define SQLITE_TRANSIENT   ((sqlite3_destructor_type)-1)
    */
    // 替换 sqlite3.h 中的宏
    private let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self)
    
    
    //CVarArgType... 类型的参数最后转换成数组
    
    func pasementInsertManyRecord(sql:String,params:CVarArgType...) ->Bool{
    
         let cSQL = sql.cStringUsingEncoding(NSUTF8StringEncoding)!
        
         //sql语句句柄
        
        var ppStmt:COpaquePointer = nil
        
        //预编译sql语句
        
        if sqlite3_prepare_v2(cOpaque, cSQL, -1, &ppStmt, nil) != SQLITE_OK {
            
           //失败需要释放句柄
            
           sqlite3_finalize(ppStmt)
            
           return false
            
        }
        
        
        
        //绑定参数------》执行之前需要给？绑定参数
        
        // * 注意：绑定参数时，值都是有序的绑定，而且绑定参数的序号需要从 1 开始
        
        //Int32是一个结构体
        
        var index:Int32 = 1
        
        for p in params {
            
            if p is Int {
                
                //整型数字绑定
                
                sqlite3_bind_int64(ppStmt, index, sqlite3_int64(p as! Int))
                
            }else if p is Double {
                
                //绑定double类型
                
                sqlite3_bind_double(ppStmt, index, p as! Double)
                
                
            }else if p is NSNull {
                
                //绑定空值
                
                sqlite3_bind_null(ppStmt, index)
                
            }else if p is String {
                
                //绑定字符串
                
                /**
                
                第2是参数的索引
                
                第3个参数是 绑定的值
                
                第4个参数是 字符串的长度
                
                
                第5个参数
                SQLITE_TRANSIENT 会对字符串做一个 copy，SQLite 选择合适的机会释放
                SQLITE_STATIC / nil  不会字符串做任何处理，如果字符串被释放，保存到数据库的内容可能不正确！
                */
                
                let stext = (p as! String).cStringUsingEncoding(NSUTF8StringEncoding)!
                
                sqlite3_bind_text(ppStmt, index, stext, -1, SQLITE_TRANSIENT)
                
                
            }
            
            
            //绑定完一个参数后，参数索引需要加一
            
            index++
            
        }
        
        
        
        //参数值绑定完之后，需要单步执行sql
        
        if sqlite3_step(ppStmt) != SQLITE_DONE {
            
            print("插入失败")
            
            return false
            
        }
        
        
        //将语句复位，以便后面绑定新的参数
        
        //数据库句柄起到一定的作用，他是永久保存起来的
        
        //虽然只是操作一条数据，但是下次执行需要绑定新的参数，如果不重置的话，数据库句柄（不是sql语句句柄）会保留以前的信息，会对绑定新的参数有干扰
        
        if sqlite3_reset(ppStmt) != SQLITE_OK {
        
          print("复位失败")
        
          return false
        
        }
        
        
        //成功
        
        return true
    }
    
    
    
//    查询数据库中的数据
    
    
    func selectRecord (sql:String) -> [[String:AnyObject]]? {
        
        
         let cSQL = sql.cStringUsingEncoding(NSUTF8StringEncoding)!
    
        //第三个参数是 csql的字节长度，我们不用自己写，如果写-1的话会自动的计算
        
        //创建一个新的句柄，将一个SQL命令字符串转换成一条prepared语句，存储在COpaquePointer类型结构体中
        
        //Statement handle  语句句柄
        
        
        
        /*
        
        sqlite3_prepareV2函数中的参数说明
        
        
        这些函数的作用是将SQL命令字符串转换为prepared语句。参数db是由sqlite3_open函数返回的指向数据库连接的指针。参数zSql是UTF-8或者
        
        UTF-16编码的SQL命令字符串，参数nByte是zSql的字节长度。如果nByte为负值，则prepare函数会自动计算出zSql的字节长度，不过要确保zSql传入的
        
        是以NULL结尾的字符串。如果SQL命令字符串中只包含一条SQL语句，那么它没有必要以“;”结尾。参数ppStmt是一个指向指针的指针，用来传回一个指向新
        
        建的sqlite3_stmt结构体的指针，sqlite3_stmt结构体里面保存有转换好的SQL语句。如果SQL命令字符串包含多条SQL语句，同时参数pzTail不为
        
        NULL，那么它将指向SQL命令字符串中的下一条SQL语句。上面4个函数中的v2版本是加强版，与原始版函数参数相同，不同的是函数内部对于sqlite3_stmt
        
        结构体的表现上
        
        sqlite3_prepare_v2返回结果是一个int sqlite_OK枚举
        
        */
        
        var ppStmt:COpaquePointer = nil   //此句柄记录的是prepared好的sql语句信息
    
        if sqlite3_prepare_v2(cOpaque, cSQL, -1, &ppStmt, nil) == SQLITE_OK {
        
          print("准备就绪")
            
        //单步执行到行的时候
            
            var dictArray = [[String:AnyObject]]()
            
            while (sqlite3_step(ppStmt) == SQLITE_ROW) {
                
            //调用解析row的函数
                
            let dict = self.oneRecord(ppStmt)
                
            //添加
                
            dictArray.append(dict)
                
            
          }    
            
        
        //将最后拼接的字典返回
            
        sqlite3_finalize(ppStmt)
            
        return dictArray
            
        }else{
        
        
          print("准备失败")
            
        
      //一定要释放语句
            
      sqlite3_finalize(ppStmt)
            
        return nil
        }
    
    }
    
    
    private func oneRecord (ppStmt:COpaquePointer) -> [String:AnyObject] {
    
        //字典存储数据
        
        var dict = [String:AnyObject]()
        
        //查看行中有多少列
        
        let colNum = sqlite3_column_count(ppStmt)
        
        
        //循环取出行中的列,这中colNum与sql语句有关系，如果sql只是填写了一个name,那么colNum的数字就为一
        
        for col in 0..<colNum {
            
            //根据列号，句柄拿出列的一些值
            
            
            //sqlite3_column_name(ppStmt, col) 返回的是c的字符
            
            let colName = String(CString: sqlite3_column_name(ppStmt, col), encoding: NSUTF8StringEncoding)!
            
            //                  print("列名是------->\(colName)")
            
            
            //列值的类型
            
            let colType = sqlite3_column_type(ppStmt, col)
            
            
            
            //根据列类型取出列中的值
            
            switch colType {
                
            case SQLITE_INTEGER:
                
                //                    print("是Int")
                
                let value = Int(sqlite3_column_int64(ppStmt, col))
                
                //将值存到字典中
                
                dict[colName] = value
                
            case SQLITE_TEXT:
                
                //                    print("是字符串")
                
                let value = UnsafePointer<Int8>(sqlite3_column_text(ppStmt, col))
                
                let value2 = String(CString: value, encoding: NSUTF8StringEncoding)
                
                dict[colName] = value2
                
            case SQLITE_FLOAT:
                
                //                    print("是Double")
                
                let value = Double(sqlite3_column_double(ppStmt, col))
                
                dict[colName] = value
                
            case SQLITE_NULL:
                
                //                    print("是NULL")
                
                //将一个nil值插入到字典中
                
                dict[colName] = NSNull()
                
            default:
                
                print("未知类型")
                
            }
            
            
            
        }
        
        
        
        //返回单个记录的结果
        
        return dict

    
    
    }
    
    
    
//    创建一张表，数据库打开成功后就可以创建一张表，移动开发，很少创建表，一般只有一张表，所以只需内部知道
    
    private func createTable () -> Bool {
    
        let sql = "CREATE TABLE IF NOT EXISTS 'T_Person' (\n" +
        "'name' text,\n" +
        "'age' INTEGER,\n" +
        "'address' TEXT,\n" +
        "'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT\n" +
        ")"
        
        //执行sql语句
        
        let result = execSQL(sql)
        
        if result {
        
           return true
            
        }else {
        
        
           return false
        }
        

    }
    
}
