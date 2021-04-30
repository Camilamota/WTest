import Foundation
//https://github.com/stephencelis/SQLite.swift
import SQLite
import SwiftUI

class DB_Manager {
    
    private var db: Connection!
    
    private var postalCode: Table!
    
    private var id: Expression<Int64>!
    private var cod_distrito: Expression<Int64>!
    private var cod_concelho: Expression<Int64>!
    private var cod_localidade: Expression<Int64>!
    private var nome_localidade: Expression<String>!
    private var cod_arteria: Expression<Int64>!
    private var tipo_arteria: Expression<String>!
    private var prep1: Expression<String>!
    private var titulo_arteria: Expression<String>!
    private var prep2: Expression<String>!
    private var nome_arteria: Expression<String>!
    private var local_arteria: Expression<String>!
    private var troco: Expression<String>!
    private var porta: Expression<String>!
    private var cliente: Expression<String>!
    private var num_cod_postal: Expression<String>!
    private var ext_cod_postal: Expression<String>!
    private var desig_postal: Expression<String>!
    
    init() {
        do
        {
            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            
            db = try! Connection("\(path)/postal_code.sqlite3")
            
            db.busyTimeout = 5

            db.busyHandler({ tries in
                if tries >= 3 {
                    return false
                }
                return true
            })
            
            postalCode = Table("PostalCode")
            id = Expression<Int64>("id")
            cod_distrito = Expression<Int64>("cod_distrito")
            cod_concelho = Expression<Int64>("cod_concelho")
            cod_localidade = Expression<Int64>("cod_localidade")
            nome_localidade = Expression<String>("nome_localidade")
            cod_arteria = Expression<Int64>("cod_arteria")
            tipo_arteria = Expression<String>("tipo_arteria")
            prep1 = Expression<String>("prep1")
            titulo_arteria = Expression<String>("titulo_arteria")
            prep2 = Expression<String>("prep2")
            nome_arteria = Expression<String>("nome_arteria")
            local_arteria = Expression<String>("local_arteria")
            troco = Expression<String>("troco")
            porta = Expression<String>("porta")
            cliente = Expression<String>("cliente")
            num_cod_postal = Expression<String>("num_cod_postal")
            ext_cod_postal = Expression<String>("ext_cod_postal")
            desig_postal = Expression<String>("desig_postal")
        }
        if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
            try! db.run(postalCode.create{
                (t) in
                t.column(id, primaryKey: true)
                t.column(cod_distrito)
                t.column(cod_concelho)
                t.column(cod_localidade)
                t.column(nome_localidade)
                t.column(cod_arteria)
                t.column(tipo_arteria)
                t.column(prep1)
                t.column(titulo_arteria)
                t.column(prep2)
                t.column(nome_arteria)
                t.column(local_arteria)
                t.column(troco)
                t.column(porta)
                t.column(cliente)
                t.column(num_cod_postal)
                t.column(ext_cod_postal)
                t.column(desig_postal)

            })
            UserDefaults.standard.set(true, forKey: "is_db_created")
        }
    }
    public func AddPostalCode(values: PostalCode){
        do {
            try db.run(postalCode.insert(cod_distrito <- values.cod_distrito,
                                          cod_concelho <- values.cod_concelho,
                                          cod_localidade <- values.cod_localidade,
                                          nome_localidade <- values.nome_localidade,
                                          cod_arteria <- values.cod_arteria,
                                          tipo_arteria <- values.tipo_arteria,
                                          prep1 <- values.prep1,
                                          titulo_arteria <- values.titulo_arteria,
                                          prep2 <- values.prep2,
                                          nome_arteria <- values.nome_arteria,
                                          local_arteria <- values.local_arteria,
                                          troco <- values.troco,
                                          porta <- values.porta,
                                          cliente <- values.cliente,
                                          num_cod_postal <- values.num_cod_postal,
                                          ext_cod_postal <- values.ext_cod_postal,
                                          desig_postal <- values.desig_postal
            ))
        } catch {
            print(error.localizedDescription)
        }
    }
    public func GetPostalCode() -> [PostalCode]{
        var postalCodeModels: [PostalCode] = []
        postalCode = postalCode.order(id.desc).limit(50000, offset: 1)
        
        do{
            for item in try! db.prepare(postalCode){
                let postalModel: PostalCode = PostalCode()
                postalModel.id = item[id]
                postalModel.cod_distrito = item[cod_distrito]
                postalModel.cod_concelho = item[cod_concelho]
                postalModel.cod_localidade = item[cod_localidade]
                postalModel.nome_localidade = item[nome_localidade]
                postalModel.prep1 = item[prep1]
                postalModel.tipo_arteria = item[tipo_arteria]
                postalModel.prep2 = item[prep2]
                postalModel.nome_arteria = item[nome_arteria]
                postalModel.local_arteria = item[local_arteria]
                postalModel.troco = item[troco]
                postalModel.porta = item[porta]
                postalModel.cliente = item[cliente]
                postalModel.num_cod_postal = item[num_cod_postal]
                postalModel.ext_cod_postal = item[ext_cod_postal]
                postalModel.desig_postal = item[desig_postal]
                
                postalCodeModels.append(postalModel)
            }
        }
        return postalCodeModels
    }
    public func DeletePostalCode(){
        try! db.run(postalCode.delete())
    }
    
    public func GetLikeValuePostalCode(value: String) -> [PostalCode]{
        var postalCodeModels: [PostalCode] = []

        let splitValue = value.split{$0 == " "}.map(String.init)
        
        print(splitValue.count)

        if(splitValue.count == 1){
            postalCode = postalCode.select(postalCode[*]).filter(desig_postal.like("%" + splitValue[0] + "%") || num_cod_postal.like("%" + splitValue[0] + "%"))
        }
        if(splitValue.count == 2){
            postalCode = postalCode.select(postalCode[*]).filter(desig_postal.like("%" + splitValue[0] + "%") || desig_postal.like("%" + splitValue[1] + "%") || num_cod_postal.like("%" + splitValue[0] + "%") || num_cod_postal.like("%" + splitValue[1] + "%"))
        }
        if(splitValue.count == 3){
            postalCode = postalCode.select(postalCode[*]).filter(desig_postal.like("%" + splitValue[0] + "%") || desig_postal.like("%" + splitValue[1] + "%") || desig_postal.like("%" + splitValue[2] + "%")  || num_cod_postal.like("%" + splitValue[0] + "%") || num_cod_postal.like("%" + splitValue[1] + "%") || num_cod_postal.like("%" + splitValue[2] + "%"))
        }
        do{
            for item in try! db.prepare(postalCode){
                let postalModel: PostalCode = PostalCode()
                postalModel.id = item[id]
                postalModel.cod_distrito = item[cod_distrito]
                postalModel.cod_concelho = item[cod_concelho]
                postalModel.cod_localidade = item[cod_localidade]
                postalModel.nome_localidade = item[nome_localidade]
                postalModel.prep1 = item[prep1]
                postalModel.tipo_arteria = item[tipo_arteria]
                postalModel.prep2 = item[prep2]
                postalModel.nome_arteria = item[nome_arteria]
                postalModel.local_arteria = item[local_arteria]
                postalModel.troco = item[troco]
                postalModel.porta = item[porta]
                postalModel.cliente = item[cliente]
                postalModel.num_cod_postal = item[num_cod_postal]
                postalModel.ext_cod_postal = item[ext_cod_postal]
                postalModel.desig_postal = item[desig_postal]
                
                postalCodeModels.append(postalModel)
            }
            print(postalCodeModels.count)
            return postalCodeModels
        }
    }
}
