USE [CS_RSL_2022]
GO

/****** Object:  View [dbo].[ContainerWiseReport]    Script Date: 16/03/2022 3:04:35 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[ContainerWiseReport] as
SELECT sjd.TransNumber,vend.FullName,customer.FullName as Client,continfo.ContainerNumb,continfo.ContainerSize,jobmaster.JobDate,hbl.hblnumber,hbl.mblnumber, 
SUM(((sjd.RecvAmount / d.TotTeus) * Case When Left(continfo.ContainerSize,2) = '40' OR Left(continfo.ContainerSize,2) = '45' THEN 2 ELSE 1 END)  * case When sjd.CurrCode = p.Currency THEN 1 ELSE isnull(sjd.ExchDClient,0) END) AS Revenue
,SUM(((sjd.PaybAmount / d.TotTeus) * Case When Left(continfo.ContainerSize,2) = '40' OR Left(continfo.ContainerSize,2) = '45' THEN 2 ELSE 1 END)  * case When sjd.CurrCode = p.Currency THEN 1 ELSE isnull(sjd.ExchDLine,0) END) AS Expense
 
FROM SEJobMaster jobmaster 
inner join SEContainerInfo continfo on jobmaster.TransNumber=continfo.Transnumber
inner join HBLMaster hbl on hbl.TransNumber=jobmaster.TransNumber
inner join SEjobDetail sjd on sjd.TransNumber=jobmaster.TransNumber
inner JOIN Vendors vend on vend.VendCode=jobmaster.VendCode
inner join CommonCoding customer on customer.CommonCode=jobmaster.CustCode
inner JOIN (   
  SELECT c.TransNumber, Sum(isnull(st.Tues,0)) AS TotTeus  FROM SEContainerInfo as c   
  inner JOIN SizeType AS st ON st.SizeCode = c.ContainerSize  
  GROUP BY c.Transnumber) AS d ON sjd.TransNumber = d.TransNumber
  CROSS JOIN parafile p
  

  GROUP BY sjd.TransNumber,vend.FullName,customer.FullName ,continfo.ContainerNumb,continfo.ContainerSize,jobmaster.JobDate,hbl.hblnumber,hbl.mblnumber
GO

