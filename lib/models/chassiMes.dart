class ChassiItem {
  final String chassi;
  final String cliente;
  final String status;

  ChassiItem({
    required this.chassi,
    required this.cliente,
    required this.status,
  });
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
//         PAI.IDENTIFICACAO AS GRUPO
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
//       const [chassi, cliente, status, ano, mesAbrev, grupo] = row;
//       const mesCompleto = `${mesesMapeados[mesAbrev.trim()] ?? mesAbrev} ${ano}`;

//       if (!dadosPorMes[mesCompleto]) dadosPorMes[mesCompleto] = {};
//       if (!dadosPorMes[mesCompleto][grupo]) dadosPorMes[mesCompleto][grupo] = [];

//       dadosPorMes[mesCompleto][grupo].push({
//         chassi,
//         cliente,
//         status
//       });
//     }

//     res.json({ dadosPorMes });
//   } catch (err) {
//     console.error("Erro ao buscar chassi:", err.message);
//     res.status(500).json({ erro: "Erro ao buscar dados", detalhes: err.message });
//   }
// });


// app.listen(3000, () => {
//   console.log("Servidor rodando em http://localhost:3000");
// });
