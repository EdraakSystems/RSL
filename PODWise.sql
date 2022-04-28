USE [CS_RSL_2022]
GO

/****** Object:  View [dbo].[PODWise]    Script Date: 16/03/2022 3:05:03 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[PODWise] as SELECT 'Export' AS JobType,'Sea' AS Mode, fp.PortUCon,fp.PortName AS POD,SEJM.JobDate, 
  (SEChargesSum.Expense+SEChargesSum.ExpenseR) AS Expense,
  (SEChargesSum.Revenue+SEChargesSum.RevenueE) AS Revenue,
  ((SEChargesSum.Revenue+SEChargesSum.RevenueE)-(SEChargesSum.Expense+SEChargesSum.ExpenseR)) AS PL,
  SEContainerSum.Total20, SEContainerSum.Total40, SEContainerSum.TEU AS TotalTEU,SEContainerSum.TotalCBM,SEContainerSum.TotalWeight
  ,VEN.VendCode,sal.LineCode,fp.PortCode AS PODCode,Cust.CustCode,lp.PortCode AS POLCode,SMan.SManCode
  ,SEJM.IsRebateClaim	--Usama : 01102019
 FROM ((((((SEJobMaster AS SEJM 
    LEFT JOIN Customers as Cust On SEJM.CustCode = Cust.Custcode)
    LEFT JOIN Vendors AS VEN ON SEJM.ForeignAgentCode = VEN.VendCode) 
    LEFT JOIN SeaAirLines AS sal ON SEJM.LineCode = sal.LineCode)   
    LEFT JOIN SalesMan AS SMan ON SEJM.SmanCode = SMan.SmanCode)
 LEFT JOIN (SELECT SEJM.TransNumber,
  Sum(Case when SEJobDetail.PaybAmount>0 then SEJobDetail.PaybAmount* Case When SEJobDetail.CurrCode =    Currency  then  1 else  SEJobDetail.ExchDLine end  else 0 end) AS Expense,
  Sum(Case when SEJobDetail.PaybAmount<0 then ABS(SEJobDetail.PaybAmount)* Case When SEJobDetail.CurrCode = Currency  then 1 else  SEJobDetail.ExchDLine end else 0 end) AS RevenueE,
  Sum(Case when SEJobDetail.RecvAmount>0 then SEJobDetail.RecvAmount* Case When SEJobDetail.CurrCode = Currency  then 1 else  SEJobDetail.ExchDClient end else 0 end) AS Revenue,
  Sum(Case when SEJobDetail.RecvAmount<0 then ABS(SEJobDetail.RecvAmount)* Case When SEJobDetail.CurrCode = Currency  then  1 else  SEJobDetail.ExchDClient end else 0 end) AS ExpenseR
 FROM SEJobMaster  SEJM
 LEFT JOIN SEJobDetail ON SEJM.TransNumber = SEJobDetail.TransNumber
 Cross join ParaFile
 GROUP BY SEJM.TransNumber ) AS SEChargesSum ON SEJM.TransNumber = SEChargesSum.TransNumber) 

 LEFT JOIN  (SELECT  SEJM.TransNumber,
  Sum(Case When SEJM.SubType=2 then Case When ContainerSize.cSize=20 then 1 else 0 end else 0 end) AS Total20, 
  Sum(Case When SEJM.SubType=2 then Case When ContainerSize.cSize>20 then 1 else 0 end else 0 end) AS Total40, 
  Sum(Case When SEJM.SubType=2 then ContainerSize.TEU else 0 end) AS TEU,
  Sum(Case When SEJM.SubType=1 then Case When ISNULL(CBM,0)=0 then 0 else CBM end else 0 end) AS TotalCBM, 
  Sum(Case When SEJM.SubType=3 or SEJM.SubType=4 then GrossWeight else 0 end) AS TotalWeight
  FROM (((SEJobMaster AS SEJM
  LEFT JOIN SEContainerInfo AS CE ON SEJM.TransNumber = CE.Transnumber)
  LEFT JOIN SizeType ON CE.ContainerSize = SizeType.SizeCode)
  LEFT JOIN ContainerType ON SizeType.SizeType = ContainerType.PkId)
  LEFT JOIN ContainerSize ON SizeType.SizeFt = ContainerSize.PkId 
  GROUP BY SEJM.TransNumber ) AS SEContainerSum ON SEJM.TransNumber = SEContainerSum.TransNumber)

 LEFT JOIN ((SERouting AS ser LEFT JOIN SeaAirPort AS lp ON ser.LoadingPort = lp.PortCode) 
 LEFT JOIN SeaAirPort AS fp ON ser.FinalDestPort = fp.PortCode) ON SEJM.TransNumber = ser.TransNumber


 UNION ALL
 SELECT  'Import' AS JobType,'Sea' AS Mode, fp.PortUCon,fp.PortName AS POD,SIJM.JobDate,
   SIChargesSum.Expense AS Expense,
   SIChargesSum.Revenue AS Revenue,
   (SIChargesSum.Revenue-SIChargesSum.Expense) AS PL,
   SIContainerSum.Total20, SIContainerSum.Total40, SIContainerSum.TEU AS TotalTEU,SIContainerSum.TotalCBM,SIContainerSum.TotalWeight
  ,VEN.VendCode,sal.LineCode,fp.PortCode AS PODCode,Cust.CustCode,lp.PortCode AS POLCode,SMan.SManCode
  ,SIJM.IsRebateClaim	--Usama : 01102019
 FROM ((((((SIJobMaster AS SIJM 
  LEFT JOIN Customers as Cust On SIJM.CustCode = Cust.Custcode)
  LEFT JOIN Vendors AS ven ON SIJM.ForeignAgentCode = ven.VendCode) 
  LEFT JOIN SeaAirLines AS sal ON SIJM.LineCode = sal.LineCode)   
  LEFT JOIN SalesMan AS SMan ON SIJM.SmanCode = SMan.SmanCode)
 LEFT JOIN (SELECT SIJM.TransNumber,
  Sum(Case When SIJobDetail.PaybAmount>0 then SIJobDetail.PaybAmount* Case When SIJobDetail.CurrCode = Currency  then 1 else  SIJobDetail.ExchDLine end  else 0 end) AS Expense,
  Sum(Case When SIJobDetail.PaybAmount<0 then ABS(SIJobDetail.PaybAmount)* Case When SIJobDetail.CurrCode = Currency  then  1 else  SIJobDetail.ExchDLine end  else 0 end) AS RevenueE,
  Sum(Case When SIJobDetail.RecvAmount>0 then SIJobDetail.RecvAmount* Case When SIJobDetail.CurrCode =  Currency  then 1 else  SIJobDetail.ExchDClient end  else 0 end) AS Revenue,
  Sum(Case When SIJobDetail.RecvAmount<0 then ABS(SIJobDetail.RecvAmount)* Case When SIJobDetail.CurrCode =  Currency  then 1 else  SIJobDetail.ExchDClient end  else 0 end) AS ExpenseR
 FROM SIJobMaster  SIJM
 LEFT JOIN SIJobDetail ON SIJM.TransNumber = SIJobDetail.TransNumber
 Cross join ParaFile
 GROUP BY SIJM.TransNumber ) AS SIChargesSum ON SIJM.TransNumber = SIChargesSum.TransNumber) 

 LEFT JOIN  (SELECT  SIJM.TransNumber,
  Sum(Case When SIJM.SubType=2 then Case When ContainerSize.cSize=20 then 1 else 0 end else 0 end) AS Total20, 
  Sum(Case When SIJM.SubType=2 then Case When ContainerSize.cSize>20 then 1 else 0 end else 0 end) AS Total40, 
  Sum(Case When SIJM.SubType=2 then ContainerSize.TEU else 0 end) AS TEU,
  Sum(Case When SIJM.SubType=1 then Case When ISNULL(CBM,0)=0 then 0 else CBM end else 0 end) AS TotalCBM, 
  Sum(Case when SIJM.SubType=3 or SIJM.SubType=4 then GrossWeight else 0 end) AS TotalWeight
  FROM (((SIJobMaster AS SIJM
  LEFT JOIN SIContainerInfo AS CI ON SIJM.TransNumber = CI.Transnumber)
  LEFT JOIN SizeType ON CI.ContainerSize = SizeType.SizeCode)
  LEFT JOIN ContainerType ON SizeType.SizeType = ContainerType.PkId)
  LEFT JOIN ContainerSize ON SizeType.SizeFt = ContainerSize.PkId 
  GROUP BY SIJM.TransNumber ) AS SIContainerSum ON SIJM.TransNumber = SIContainerSum.TransNumber)

 LEFT JOIN ((SIRouting AS sir LEFT JOIN SeaAirPort AS lp ON sir.LoadingPort = lp.PortCode)
 LEFT JOIN SeaAirPort AS fp ON sir.FinalDestPort = fp.PortCode) ON SIJM.TransNumber = sir.TransNumber

 UNION ALL

 SELECT   'Export' AS JobType,'Air' AS Mode,fp.PortUCon,fp.PortName AS POD,AEJM.JobDate, 
  (AEChargesSum.Expense+AEChargesSum.ExpenseR) AS Expense,
  (AEChargesSum.Revenue+AEChargesSum.RevenueE) AS Revenue,
  ((AEChargesSum.Revenue+AEChargesSum.RevenueE)-(AEChargesSum.Expense+AEChargesSum.ExpenseR)) AS PL,
  0 AS Total20, 0 AS Total40, 0 AS TotalTEU,0 AS TotalCBM,AEJM.[WEIGHT] AS TotalWeight
  ,VEN.VendCode,sal.LineCode,fp.PortCode AS PODCode,Cust.CustCode,lp.PortCode AS POLCode,SMan.SManCode
  ,AEJM.IsRebateClaim	--Usama : 01102019
 FROM (((((AEJobMaster AS AEJM 
    LEFT JOIN Customers as Cust On AEJM.CustCode = Cust.Custcode)
    LEFT JOIN Vendors AS VEN ON AEJM.ForeignAgentCode = VEN.VendCode) 
    LEFT JOIN SeaAirLines AS sal ON AEJM.LineCode = sal.LineCode)    
    LEFT JOIN SalesMan AS SMan ON AEJM.SmanCode = SMan.SmanCode)
 LEFT JOIN (SELECT AEJM.TransNumber,
  Sum(Case When AEJobDetail.PaybAmount>0 then AEJobDetail.PaybAmount* Case When AEJobDetail.CurrCode =    Currency  then 1 else   AEJobDetail.ExchDLine End else 0 end) AS Expense,
  Sum(Case When AEJobDetail.PaybAmount<0 then ABS(AEJobDetail.PaybAmount)* Case When AEJobDetail.CurrCode = Currency then 1 else   AEJobDetail.ExchDLine End else 0 end) AS RevenueE,
  Sum(Case When AEJobDetail.RecvAmount>0 then AEJobDetail.RecvAmount* Case When AEJobDetail.CurrCode = Currency then 1 else  AEJobDetail.ExchDClient End else 0 end) AS Revenue,
  Sum(Case When AEJobDetail.RecvAmount<0 then ABS(AEJobDetail.RecvAmount)* Case When AEJobDetail.CurrCode = Currency then 1 else  AEJobDetail.ExchDClient End else 0 end) AS ExpenseR
 FROM AEJobMaster  AEJM
 LEFT JOIN AEJobDetail ON AEJM.TransNumber = AEJobDetail.TransNumber
 Cross join ParaFile
 GROUP BY AEJM.TransNumber ) AS AEChargesSum ON AEJM.TransNumber = AEChargesSum.TransNumber) 

 LEFT JOIN ((AERouting AS ser LEFT JOIN SeaAirPort AS lp ON ser.LoadingPort = lp.PortCode) 
 LEFT JOIN SeaAirPort AS fp ON ser.FinalDestPort = fp.PortCode) ON AEJM.TransNumber = ser.TransNumber



 UNION ALL

 SELECT 'Import' AS JobType,'Air' AS Mode,fp.PortUCon,fp.PortName AS POD,AIJM.JobDate, 
  (AIChargesSum.Expense+AIChargesSum.ExpenseR) AS Expense,
  (AIChargesSum.Revenue+AIChargesSum.RevenueE) AS Revenue,
  ((AIChargesSum.Revenue+AIChargesSum.RevenueE)-(AIChargesSum.Expense+AIChargesSum.ExpenseR)) AS PL,
  0 AS Total20, 0 AS Total40, 0 AS TotalTEU,0 AS TotalCBM,AIBL.GrossWeight AS TotalWeight
  ,VEN.VendCode,sal.LineCode,fp.PortCode AS PODCode,Cust.CustCode,lp.PortCode AS POLCode,SMan.SManCode
  ,AIJM.IsRebateClaim	--Usama : 01102019
 FROM ((((((AIJobMaster AS AIJM 
    LEFT JOIN Customers as Cust On AIJM.CustCode = Cust.Custcode)
    LEFT JOIN Vendors AS VEN ON AIJM.ForeignAgentCode = VEN.VendCode) 
    LEFT JOIN SeaAirLines AS sal ON AIJM.LineCode = sal.LineCode)    
    LEFT JOIN SalesMan AS SMan ON AIJM.SmanCode = SMan.SmanCode)
    LEFT JOIN AIBL ON AIBL.TransNumber = AIJM.TransNumber)
 LEFT JOIN (SELECT AIJM.TransNumber,
  Sum(Case When AIJobDetail.PaybAmount>0 then AIJobDetail.PaybAmount* Case When AIJobDetail.CurrCode =   Currency then 1 else  AIJobDetail.ExchDLine End Else 0 End ) AS Expense,
  Sum(Case When AIJobDetail.PaybAmount<0 then ABS(AIJobDetail.PaybAmount)* Case When AIJobDetail.CurrCode = Currency  then 1 else  AIJobDetail.ExchDLine End Else 0 End) AS RevenueE,
  Sum(Case When AIJobDetail.RecvAmount>0 then AIJobDetail.RecvAmount* Case When AIJobDetail.CurrCode = Currency  then 1 else  AIJobDetail.ExchDClient End Else 0 End) AS Revenue,
  Sum(Case When AIJobDetail.RecvAmount<0 then ABS(AIJobDetail.RecvAmount)* Case When AIJobDetail.CurrCode =  Currency  then 1 else  AIJobDetail.ExchDClient End Else 0 End) AS ExpenseR
 FROM AIJobMaster  AIJM
 LEFT JOIN AIJobDetail ON AIJM.TransNumber = AIJobDetail.TransNumber
 Cross join ParaFile
 GROUP BY AIJM.TransNumber ) AS AIChargesSum ON AIJM.TransNumber = AIChargesSum.TransNumber) 

 LEFT JOIN ((AIRouting AS ser LEFT JOIN SeaAirPort AS lp ON ser.LoadingPort = lp.PortCode) 
 LEFT JOIN SeaAirPort AS fp ON ser.FinalDestPort = fp.PortCode) ON AIJM.TransNumber = ser.TransNumber

 UNION ALL SELECT 'Road' AS JobType,'Transport' AS Mode,fp.PortUCon, fp.PortName AS POD,TM.JobDate, 
  (AEChargesSum.Expense+AEChargesSum.ExpenseR) AS Expense,
  (AEChargesSum.Revenue+AEChargesSum.RevenueE) AS Revenue,
  ((AEChargesSum.Revenue+AEChargesSum.RevenueE)-(AEChargesSum.Expense+AEChargesSum.ExpenseR)) AS PL,
  0 AS Total20, 0 AS Total40, 0 AS TotalTEU,0 AS TotalCBM,TM.[WEIGHT] AS TotalWeight
  ,VEN.VendCode,sal.LineCode,fp.PortCode AS PODCode,Cust.CustCode,lp.PortCode AS POLCode,SMan.SManCode
  ,'' AS IsRebateClaim	--Usama : 01102019
 FROM (((((TransportMaster AS TM 
    LEFT JOIN Customers as Cust On TM.CustCode = Cust.Custcode)
    LEFT JOIN Vendors AS VEN ON TM.VendCode = VEN.VendCode) 
    LEFT JOIN SeaAirLines AS sal ON TM.LineCode = sal.LineCode)    
    LEFT JOIN SalesMan AS SMan ON TM.SmanCode = SMan.SmanCode)
 LEFT JOIN (SELECT TM.TransNumber,
  Sum(Case When TransportDetail.PaybAmount>0 then TransportDetail.PaybAmount* Case When TransportDetail.CurrCode = Currency then 1 else   TransportDetail.ExchDLine end else 0 end) AS Expense,
  Sum(Case When TransportDetail.PaybAmount<0 then ABS(TransportDetail.PaybAmount)* Case When TransportDetail.CurrCode = Currency then 1 else  TransportDetail.ExchDLine end else 0 end) AS RevenueE,
  Sum(Case When TransportDetail.RecvAmount>0 then TransportDetail.RecvAmount* Case When TransportDetail.CurrCode = Currency then 1 else  TransportDetail.ExchDClient end else 0 end) AS Revenue,
  Sum(Case When TransportDetail.RecvAmount<0 then ABS(TransportDetail.RecvAmount)* Case When TransportDetail.CurrCode = Currency  then 1 else  TransportDetail.ExchDClient end else 0 end) AS ExpenseR
 FROM TransportMaster  TM
 LEFT JOIN TransportDetail ON TM.TransNumber = TransportDetail.TransNumber
 cross join ParaFile
 GROUP BY TM.TransNumber ) AS AEChargesSum ON TM.TransNumber = AEChargesSum.TransNumber) 

 LEFT JOIN ((AERouting AS ser LEFT JOIN SeaAirPort AS lp ON ser.LoadingPort = lp.PortCode) 
  LEFT JOIN SeaAirPort AS fp ON ser.FinalDestPort = fp.PortCode) ON TM.TransNumber = ser.TransNumber

GO

