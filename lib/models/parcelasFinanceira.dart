class ResumoFinanceiroModel {
  final String chassi;
  final String titulo;
  final String vlrPago;
  final String vlrAVencer;
  final String vlrAVencido;
  final String diasAtrasos;
  final String nufin;
  final String nunota;
  final String vlrParcela;
  final String status;

  ResumoFinanceiroModel({
    required this.chassi,
    required this.titulo,
    required this.vlrPago,
    required this.vlrAVencer,
    required this.vlrAVencido,
    required this.diasAtrasos,
    required this.nufin,
    required this.nunota,
    required this.vlrParcela,
    required this.status,
  });

  factory ResumoFinanceiroModel.fromJson(Map<String, dynamic> json) {
    return ResumoFinanceiroModel(
      chassi: json['chassi']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      vlrPago: json['vlrpago']?.toString() ?? '0',
      vlrAVencer: json['vlravencer']?.toString() ?? '0',
      vlrAVencido: json['vlravencido']?.toString() ?? '0',
      diasAtrasos: json['diasatrasos']?.toString() ?? '0',
      nufin: json['nufin']?.toString() ?? '',
      nunota: json['nunota']?.toString() ?? '',
      vlrParcela: json['vlrparcela']?.toString() ?? '0',
      status: json['status']?.toString() ?? '',
    );
  }

  /// Exemplo de cálculo em tempo de uso
  double get valorParcelaDouble => double.tryParse(vlrParcela) ?? 0.0;

  String get statusString {
    final vencido = double.tryParse(vlrAVencido) ?? 0;
    final aberto = double.tryParse(vlrAVencer) ?? 0;
    final pago = double.tryParse(vlrPago) ?? 0;

    if (vencido > 0) return "Vencido";
    if (aberto > 0) return "Aberto";
    if (pago > 0) return "Pago";
    return "Indefinido";
  }
}



// const express = require('express');
// const axios = require('axios');
// const cors = require('cors');

// const app = express();
// app.use(cors());
// app.use(express.json());

// // CONFIGURAÇÕES
// const SANKHYA_URL = 'http://sankhya2.nxboats.com.br:8180';
// const USUARIO = 'SUP';
// const SENHA = 'Sup#ti@88#3448';

// // LOGIN NO SANKHYA
// async function loginSankhya() {
//   const response = await axios.post(`${SANKHYA_URL}/mge/service.sbr?serviceName=MobileLoginSP.login&outputType=json`, {
//     serviceName: "MobileLoginSP.login",
//     requestBody: {
//       NOMUSU: { "$": USUARIO },
//       INTERNO: { "$": SENHA },
//       KEEPCONNECTED: { "$": "S" }
//     }
//   }, {
//     headers: { 'Content-Type': 'application/json' }
//   });

//   const jsessionid = response.data.responseBody?.jsessionid?.["$"];
//   if (!jsessionid) throw new Error("Login falhou");
//   return `JSESSIONID=${jsessionid}`;
// }

// // ROTA PARA CONSULTAR ITENS DO PEDIDO
// app.get('/api/itens-pedido', async (req, res) => {
//   const nunota = req.query.nunota;

//   if (!nunota) {
//     return res.status(400).json({ erro: "Parâmetro 'nunota' é obrigatório na URL." });
//   }

//   try {
//     const sessionId = await loginSankhya();

//     const sql = `
//       SELECT
//         IP.NUNOTA AS NUNOTA,
//         CAST(P.DESCRPROD AS VARCHAR(4000)) AS DESCRPROD,
//         IP.QTDNEG AS QTDNEG,
//         IP.VLRUNIT AS VLRUNIT,
//         NVL(PAP.CODPROPARC,'Sem Referencia') AS CODPROPARC
//       FROM TGFITE IP
//       JOIN TGFCAB C ON C.NUNOTA = IP.NUNOTA
//       JOIN TGFPRO P ON P.CODPROD = IP.CODPROD
//       LEFT JOIN TGFPAP PAP  ON  IP.CODPROD = PAP.CODPROD AND C.CODPARC = PAP.CODPARC
//       WHERE IP.NUNOTA = ${nunota}
//     `;


//     const consulta = {
//       serviceName: "DbExplorerSP.executeQuery",
//       requestBody: {
//         sql,
//         outputType: "json"
//       }
//     };

//     const response = await axios.post(
//       `${SANKHYA_URL}/mge/service.sbr?serviceName=DbExplorerSP.executeQuery&outputType=json`,
//       consulta,
//       {
//         headers: {
//           'Content-Type': 'application/json',
//           'Cookie': sessionId
//         }
//       }
//     );

//     const linhas = response.data.responseBody?.rows || [];

//     const itens = linhas.map(row => ({
//       nomeProduto: String(row[1]).normalize('NFC'),
//       qtd: row[2],
//       vlrUnit: row[3],
//       codProparc: row[4]
//     }));

//     res.json({ itens });
//     console.log("Linhas recebidas:", response.data.responseBody?.rows);

//   } catch (err) {
//     console.error("Erro ao consultar itens com DbExplorer:", err.message);
//     res.status(500).json({ erro: "Falha ao buscar itens com SQL direto", detalhes: err.message });
//   }
// });

// // ROTA PARA CONSULTAR CABEÇALHO DO PEDIDO
// app.get('/api/cabecalho-pedido', async (req, res) => {
//   const nunota = req.query.nunota;
//   if (!nunota) return res.status(400).json({ erro: "Parâmetro 'nunota' é obrigatório." });

//   try {
//     const sessionId = await loginSankhya();

//     const sql = `
//       SELECT
//         CAB.CODPARC || ' - ' || PAR.RAZAOSOCIAL AS PARCEIRO,
//         ENDE.TIPO || ' ' || ENDE.NOMEEND || ', ' || PAR.NUMEND AS ENDERECO,
//         PAR.CEP,
//         CID.NOMECID || '-' || UFS.UF AS CIDADE,
//         Formatar_Cpf_Cnpj(PAR.CGC_CPF) AS CGC,
//         PAR.IDENTINSCESTAD,
//         PAR.CODVEND || ' - ' || VEN.APELIDO AS VENDEDOR,
//         CAB.DTNEG,
//         CAB.NUNOTA
//       FROM TGFCAB CAB
//       JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
//       JOIN TSIEND ENDE ON ENDE.CODEND = PAR.CODEND
//       LEFT JOIN TSICID CID ON CID.CODCID = PAR.CODCID
//       LEFT JOIN TSIUFS UFS ON UFS.CODUF = CID.UF
//       LEFT JOIN TGFVEN VEN ON VEN.CODVEND = PAR.CODVEND
//       WHERE CAB.NUNOTA = ${nunota}
//     `;

//     const consulta = {
//       serviceName: "DbExplorerSP.executeQuery",
//       requestBody: {
//         sql,
//         outputType: "json"
//       }
//     };

//     const response = await axios.post(
//       `${SANKHYA_URL}/mge/service.sbr?serviceName=DbExplorerSP.executeQuery&outputType=json`,
//       consulta,
//       {
//         headers: {
//           'Content-Type': 'application/json',
//           'Cookie': sessionId
//         }
//       }
//     );

//     const row = response.data.responseBody?.rows?.[0];
//     if (!row) {
//       return res.status(404).json({ erro: "Cabeçalho não encontrado." });
//     }

//     const cabecalho = {
//       parceiro: row[0],
//       endereco: row[1],
//       cep: row[2],
//       cidade: row[3],
//       cgc: row[4],
//       rgIe: row[5],
//       vendedor: row[6],
//       dataNegociacao: row[7],
//       nunota: row[8]
//     };

//     res.json(cabecalho);
//   } catch (err) {
//     console.error("Erro ao buscar cabeçalho:", err.message);
//     res.status(500).json({ erro: "Erro ao buscar cabeçalho", detalhes: err.message });
//   }
// });

// // ROTA PARA CONSULTAR CABEÇALHO DO PEDIDO
// app.get('/api/chassi', async (req, res) => {
//   try {
//     const sessionId = await loginSankhya();

//     const sql = `
//       SELECT 
      
//         PRJ.IDENTIFICACAO AS CHASSI,
//         PAR.NOMEPARC AS CLIENTE,
//         F_DESCROPC('TGFCAB', 'STATUSNOTA', CAB.STATUSNOTA) AS STATUS,
//         TO_CHAR(CAB.DTNEG,'YYYY') AS ANO,
//         TO_CHAR(CAB.DTNEG,'MON') AS MES,
//         PAI.IDENTIFICACAO AS GRUPO,
//         ROW_NUMBER() OVER (ORDER BY CAB.DTNEG) AS SEQUENCIA
//       FROM TGFCAB CAB 
//       JOIN TCSPRJ PRJ ON PRJ.CODPROJ = CAB.CODPROJ
//       JOIN TCSPRJ PAI ON PAI.CODPROJ = PRJ.CODPROJPAI
//       JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC 
//       WHERE CAB.TIPMOV = 'P'
//         AND TO_CHAR(CAB.DTNEG,'MM/YYYY') in ('06/2025' ,'05/2025') 
//         AND CAB.CODPROJ > 0 
//     `;

//     const consulta = {
//       serviceName: "DbExplorerSP.executeQuery",
//       requestBody: {
//         sql,
//         outputType: "json"
//       }
//     };

//     const response = await axios.post(
//       `${SANKHYA_URL}/mge/service.sbr?serviceName=DbExplorerSP.executeQuery&outputType=json`,
//       consulta,
//       {
//         headers: {
//           'Content-Type': 'application/json',
//           'Cookie': sessionId
//         }
//       }
//     );

//     const rows = response.data.responseBody?.rows || [];

//     const mesesMapeados = {
//       'JAN': 'Janeiro', 'FEB': 'Fevereiro', 'MAR': 'Março', 'APR': 'Abril',
//       'MAY': 'Maio', 'JUN': 'Junho', 'JUL': 'Julho', 'AUG': 'Agosto',
//       'SEP': 'Setembro', 'OCT': 'Outubro', 'NOV': 'Novembro', 'DEC': 'Dezembro'
//     };

//     const dadosPorMes = {};

//     for (const row of rows) {
//       const [chassi, cliente, status, ano, mesAbrev, grupo , sequencia] = row;
//       const mesCompleto = `${mesesMapeados[mesAbrev.trim()] ?? mesAbrev} ${ano}`;

//       if (!dadosPorMes[mesCompleto]) dadosPorMes[mesCompleto] = {};
//       if (!dadosPorMes[mesCompleto][grupo]) dadosPorMes[mesCompleto][grupo] = [];

//       dadosPorMes[mesCompleto][grupo].push({
//         chassi,
//         cliente,
//         status,
//         sequencia
//       });
//     }

//     res.json({ dadosPorMes });
//   } catch (err) {
//     console.error("Erro ao buscar chassi:", err.message);
//     res.status(500).json({ erro: "Erro ao buscar dados", detalhes: err.message });
//   }
// });

// // ROTA PARA CONSULTAR CABEÇALHO DO PEDIDO
// app.get('/api/chassifinanceiro', async (req, res) => {
//   const nunota = req.query.nunota;
//   if (!nunota) return res.status(400).json({ erro: "Parâmetro 'nunota' é obrigatório." });

//   try {
//     const sessionId = await loginSankhya();

//     const sql = `
//       SELECT
//           PRJ.IDENTIFICACAO AS CHASSI,
//           TIT.DESCRTIPTIT AS TITULO,
//           CASE WHEN DET.FAROL =  '<span style="display:inline-block;width:12px;height:12px;border-radius:50%;background-color:#0d4f9b;"></span>' 
//           THEN VLRPARCELA ELSE 0 END AS VLRPAGO,
//           CASE WHEN DET.VLRABERTO > 0 AND DET.DTVENC >= SYSDATE THEN VLRPARCELA ELSE 0 END  AS VLRAVENCER,  
//           CASE WHEN DET.VLRABERTO > 0 AND DET.DTVENC < SYSDATE THEN VLRPARCELA ELSE 0 END  AS VLRAVENCIDO, 
//           CASE WHEN TO_CHAR(DET.DTVENC,'DD/MM/YYYY') > TO_CHAR(SYSDATE ,'DD/MM/YYYY') THEN 0 ELSE DIASATRASO END AS DIASATRASOS,
//           TO_CHAR(DET.DTVENC,'DD/MM/YYYY') AS DTVENC,
//           DET.NUFIN,
//           DET.NUNOTA,
//           DET.VLRPARCELA,
//           CASE WHEN DET.FAROL = '<span style="display:inline-block;width:12px;height:12px;border-radius:50%;background-color:#9b0d0d;"></span>' THEN 'ATRASADO'
// WHEN  DET.FAROL = '<span style="display:inline-block;width:12px;height:12px;border-radius:50%;background-color:#0d9b14;"></span>' THEN 'EM ABERTO'
// WHEN  DET.FAROL = '<span style="display:inline-block;width:12px;height:12px;border-radius:50%;background-color:#0d4f9b;"></span>' THEN 'PAGO'
//  END AS STATUS

//           FROM AD_FINGERCODET DET
//           JOIN TGFCAB CAB ON CAB.NUNOTA = DET.NUNOTA 
//           JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
//           JOIN TCSPRJ PRJ ON PRJ.CODPROJ = CAB.CODPROJ
//           JOIN TGFTIT TIT ON TIT.CODTIPTIT = DET.CODTIPTIT
//           WHERE  PRJ.IDENTIFICACAO = '${nunota}'
//     `;

//     const consulta = {
//       serviceName: "DbExplorerSP.executeQuery",
//       requestBody: {
//         sql,
//         outputType: "json"
//       }
//     };

//     const response = await axios.post(
//       `${SANKHYA_URL}/mge/service.sbr?serviceName=DbExplorerSP.executeQuery&outputType=json`,
//       consulta,
//       {
//         headers: {
//           'Content-Type': 'application/json',
//           'Cookie': sessionId
//         }
//       }
//     );

//     const linhas = response.data.responseBody?.rows || [];
   


//     const itens = linhas.map(row => ({
//       chassi: row[0],
//       titulo: row[1],
//       vlrpago: row[2],
//       vlravencer: row[3],
//       vlravencido: row[4],
//       diasatrasos: row[5],
//       dtvenc: row[6] ,
   
//       nufin: row[7],
//       nunota: row[8],
//       vlrparcela: row[8], 
//       status: row[10]
// }));

// res.json({ itens });
// console.log("Linhas recebidas:", response.data.responseBody?.rows);
//   } catch (err) {
//     console.error("Erro ao buscar cabeçalho:", err.message);
//     res.status(500).json({ erro: "Erro ao buscar cabeçalho", detalhes: err.message });
//   }
// });

// // const linhas = response.data.responseBody?.rows || [];

// // const itens = linhas.map(row => ({
// //   nomeProduto: String(row[1]).normalize('NFC'),
// //   qtd: row[2],
// //   vlrUnit: row[3],
// //   codProparc: row[4]
// // }));

// // res.json({ itens });
// // console.log("Linhas recebidas:", response.data.responseBody?.rows);

// // } catch (err) {
// // console.error("Erro ao consultar itens com DbExplorer:", err.message);
// // res.status(500).json({ erro: "Falha ao buscar itens com SQL direto", detalhes: err.message });
// // }


// app.listen(3000, () => {
//   console.log("Servidor rodando em http://localhost:3000");
// });
