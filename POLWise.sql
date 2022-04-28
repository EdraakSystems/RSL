USE [CS_RSL_2022]
GO

/****** Object:  View [dbo].[POLWise]    Script Date: 28/04/2022 1:13:02 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[POLWise] as SELECT 'Export' AS JobType,'Sea' AS Mode,lp.PortUCon,
  lp.PortName AS Portt,SEJM.JobDate, 
  (SEChargesSum.Expense+SEChargesSum.ExpenseR) AS Expense,
  (SEChargesSum.Revenue+SEChargesSum.RevenueE) AS Revenue,
  ((SEChargesSum.Revenue+SEChargesSum.RevenueE)-(SEChargesSum.Expense+SEChargesSum.ExpenseR)) AS PL,
  SEContainerSum.Total20, SEContainerSum.Total40, SEContainerSum.TEU AS TotalTEU,SEContainerSum.TotalCBM,SEContainerSum.TotalWeight
  ,fp.PortCode AS PODCode,lp.PortCode AS POLCode
  ,SEJM.IsRebateClaim	--Usama : 01102019
 FROM ((SEJobMaster AS SEJM 
    

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
 SELECT  'Import' AS JobType,'Sea' AS Mode,  lp.PortUCon,
   
   lp.PortName AS Portt,SIJM.JobDate,
   SIChargesSum.Expense AS Expense,
   SIChargesSum.Revenue AS Revenue,
   (SIChargesSum.Revenue-SIChargesSum.Expense) AS PL,
   SIContainerSum.Total20, SIContainerSum.Total40, SIContainerSum.TEU AS TotalTEU,SIContainerSum.TotalCBM,SIContainerSum.TotalWeight
  ,fp.PortCode AS PODCode,lp.PortCode AS POLCode
  ,SIJM.IsRebateClaim	--Usama : 01102019
 FROM ((SIJobMaster AS SIJM 
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

 
GO

