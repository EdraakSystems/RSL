USE [CS_RSL_2022]
GO

/****** Object:  View [dbo].[SE_Overall_Summary]    Script Date: 28/04/2022 1:10:44 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create  view [dbo].[SE_Overall_Summary] as
SELECT 'Export' AS JobType,'Sea' AS Mode,SEJM.JobNumber,hbl.hblnumber,Cust.FullName as Client,SMan.FullName AS SalesPerson,
   sal.FullName AS ShippingLine,
  lp.PortName AS POL, fp.PortName AS POD,secont.ContainerNumb,principle.Name as Principle,SEJM.JobDate, 
  (SEChargesSum.Expense+SEChargesSum.ExpenseR) AS Expense,
  (SEChargesSum.Revenue+SEChargesSum.RevenueE) AS Revenue,
  ((SEChargesSum.Revenue+SEChargesSum.RevenueE)-(SEChargesSum.Expense+SEChargesSum.ExpenseR)) AS PL,
  SEContainerSum.Total20, SEContainerSum.Total40, SEContainerSum.TEU AS TotalTEU,SEContainerSum.TotalCBM,SEContainerSum.TotalWeight
  ,sal.LineCode,fp.PortCode AS PODCode,Cust.CustCode,lp.PortCode AS POLCode,SMan.SManCode
  ,SEJM.IsRebateClaim	--Usama : 01102019
 FROM (((((((((SEJobMaster AS SEJM 
    LEFT JOIN Customers as Cust On SEJM.CustCode = Cust.Custcode)
    
    LEFT JOIN SeaAirLines AS sal ON SEJM.LineCode = sal.LineCode)   
    LEFT JOIN SalesMan AS SMan ON SEJM.SmanCode = SMan.SmanCode)
	LEFT JOIN SEContainerInfo secont on secont.Transnumber=SEJM.TransNumber)
	LEFT JOIN HBLMaster hbl on SEJM.JobNumber=hbl.JobNumber)
	LEFT JOIN [Ctrack_RSL_ISOTank].[dbo].[Containers] nvocc on nvocc.CntNo=secont.ContainerNumb)
		LEFT JOIN [Ctrack_RSL_ISOTank].[dbo].[PrincipleSetup] principle on principle.PKID=nvocc.PrincipleID)
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
GO

