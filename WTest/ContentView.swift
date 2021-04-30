import SwiftUI
//https://github.com/yaslab/CSV.swift
import CSV

//Ao iniciar o app sera feito o download do arquivo .csv e gravado no sqlite.
//uma vez gravados todos as Informações, ao iniciar o app nao sera feito novamente o download.
//caso o aplicativo seja fechado antes de finalizar o download, todos os dados gravados no sqlite serao excluidos e irao começar novamente o processo.


struct ContentView: View {
    
    @ObservedObject private var kGuardian = KeyboardGuardian(textFieldCount: 1)
    @State var name = "Downloading"
    @State var listPostalCode: [PostalCode] = []
    @State var placeHolderMessage: String = "Esperando o download"
    @State private var fullText: String = ""
    @State private var isLoad: Bool = true

    var body: some View {
        Text(name)
        TextField(placeHolderMessage ,text: $fullText)
                        .padding()
                        .foregroundColor(Color.red)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 70)
                        .border(Color.black, width: 1)
            .disabled(isLoad)
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) {
                            _ in
                            DispatchQueue.global(qos: .userInitiated).async {
                                listPostalCode.removeAll()
                                isLoad = true
                                let responseList = DB_Manager().GetLikeValuePostalCode(value: fullText)
                                listPostalCode = responseList
                                isLoad = false
                            }
                }
        List (self.listPostalCode) {(model) in
            HStack {
                Text(model.desig_postal)
                Text(model.num_cod_postal + "-" + model.ext_cod_postal)
            }
        }
        .onAppear(perform: {
            let valuesInSqlite = DB_Manager().GetPostalCode()
            print(valuesInSqlite.count)
            if(valuesInSqlite.count > 326000){
                listPostalCode = valuesInSqlite
                isLoad = false
            }else{
                DB_Manager().DeletePostalCode()
                DispatchQueue.global(qos: .userInitiated).async {
                    if let url = URL(string: "https://raw.githubusercontent.com/centraldedados/codigos_postais/master/data/codigos_postais.csv") {
                        do {
                            let contents = try String(contentsOf: url)
                            let csvString = contents
                            let csv = try! CSVReader(string: csvString, hasHeaderRow: true)
                            var count: Int64 = 0
                            while let row = csv.next() {
                                let valuesInsert = PostalCode()
                                valuesInsert.cod_distrito = Int64(row[0]) ?? 0
                                valuesInsert.cod_concelho = Int64(row[1]) ?? 0
                                valuesInsert.cod_localidade = Int64(row[2]) ?? 0
                                valuesInsert.nome_localidade = row[3]
                                valuesInsert.cod_arteria = Int64(row[4]) ?? 0
                                valuesInsert.tipo_arteria = row[5]
                                valuesInsert.prep1 = row[6]
                                valuesInsert.tipo_arteria = row[7]
                                valuesInsert.prep2 = row[8]
                                valuesInsert.nome_arteria = row[9]
                                valuesInsert.local_arteria = row[10]
                                valuesInsert.troco = row[11]
                                valuesInsert.porta = row[12]
                                valuesInsert.cliente = row[13]
                                valuesInsert.num_cod_postal = row[14]
                                valuesInsert.ext_cod_postal = row[15]
                                valuesInsert.desig_postal = row[16]
                                DB_Manager().AddPostalCode(values: valuesInsert)
                                count = count + 1
                                name = "Executando: " + String(count) + "/326330"
                            }
                            let test = DB_Manager().GetPostalCode()
                            listPostalCode = test
                            isLoad = false
                            placeHolderMessage = "Procurar"
                        } catch {
                        }
                    } else {
                    }
                }
            }
        }).offset(y: kGuardian.slide).animation(.easeInOut(duration: 1.0))
        if (isLoad){
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(3)
                .disabled(true)
                .ignoresSafeArea()
                .frame(width: 50, height: 50, alignment: .center)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
