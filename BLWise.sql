USE [CS_RSL_2022]
GO

/****** Object:  View [dbo].[BL_wise_report]    Script Date: 16/03/2022 3:03:57 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[BL_wise_report] as 
 SELECT contact.BLNo,vend.FullName,continfo.ContainerNumb,continfo.ContainerSize,jobmaster.JobDate,hbl.hblnumber,hbl.mblnumber,   
SUM(((sjd.RecvAmount / d.TotTeus) * Case When Left(continfo.ContainerSize,2) = '40' OR Left(continfo.ContainerSize,2) = '45' THEN 2 ELSE 1 END)  * case When sjd.CurrCode = p.Currency THEN 1 ELSE isnull(sjd.ExchDClient,0) END) AS Revenue  
,SUM(((sjd.PaybAmount / d.TotTeus) * Case When Left(continfo.ContainerSize,2) = '40' OR Left(continfo.ContainerSize,2) = '45' THEN 2 ELSE 1 END)  * case When sjd.CurrCode = p.Currency THEN 1 ELSE isnull(sjd.ExchDLine,0) END) AS Expense  
   
FROM CS_RSL_2022.dbo.SEJobMaster jobmaster   
inner join CS_RSL_2022.dbo.SEContainerInfo continfo on jobmaster.TransNumber=continfo.Transnumber  
inner join CS_RSL_2022.dbo.HBLMaster hbl on hbl.TransNumber=jobmaster.TransNumber  
inner join CS_RSL_2022.dbo.SEjobDetail sjd on sjd.TransNumber=jobmaster.TransNumber  
inner JOIN CS_RSL_2022.dbo.Vendors vend on vend.VendCode=jobmaster.VendCode  
INNER JOIN Ctrack_RSL_ISOTank.dbo.Containers nvccCont on nvccCont.CntNo=continfo.ContainerNumb
INNER JOIN Ctrack_RSL_ISOTank.dbo.ContainerActivity contact on contact.CntID=nvccCont.CntID
inner JOIN (     
  SELECT c.TransNumber, Sum(isnull(st.Tues,0)) AS TotTeus  FROM CS_RSL_2022.dbo.SEContainerInfo as c     
  inner JOIN CS_RSL_2022.dbo.SizeType AS st ON st.SizeCode = c.ContainerSize    
  GROUP BY c.Transnumber) AS d ON sjd.TransNumber = d.TransNumber  
  CROSS JOIN CS_RSL_2022.dbo.parafile p  
  GROUP BY contact.BLNo,vend.FullName,continfo.ContainerNumb,continfo.ContainerSize,jobmaster.JobDate,hbl.hblnumber,hbl.mblnumber 
GO

