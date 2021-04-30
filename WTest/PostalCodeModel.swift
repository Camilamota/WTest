import Foundation

public class PostalCode: Identifiable {
    public var id: Int64 = 0
    public var cod_distrito: Int64 = 0
    public var cod_concelho: Int64 = 0
    public var cod_localidade: Int64 = 0
    public var nome_localidade: String = ""
    public var cod_arteria: Int64 = 0
    public var tipo_arteria: String = ""
    public var prep1: String = ""
    public var titulo_arteria: String = ""
    public var prep2: String = ""
    public var nome_arteria: String = ""
    public var local_arteria: String = ""
    public var troco: String = ""
    public var porta: String = ""
    public var cliente: String = ""
    public var num_cod_postal: String = ""
    public var ext_cod_postal: String = ""
    public var desig_postal: String = ""
}

