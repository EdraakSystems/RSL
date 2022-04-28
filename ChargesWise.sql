USE [CS_RSL_2022]
GO

/****** Object:  View [dbo].[ChargesWiseReport_pbi]    Script Date: 16/03/2022 3:04:13 pm ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE  view [dbo].[ChargesWiseReport_pbi] as 
SELECT   distinct( jobmaster.TransNumber),charg.FullName as Charges,jobmaster.JobNumber,jobmaster.JobDate,hbl.hblnumber,hbl.mblnumber,cust.FullName as PartyName,  
case  when cns.FullName is not null then cns.FullName else '' end as Consignee,ship.FullName as Shipper,semore.ShipperCode,vsl.VesselName  
,SJd.CurrCode,(sjd.RecvQuantity) as Quantity,(sjd.RecvRate) as Rate,(sjd.RecvAmount) as Amount , sjd.RecvAmount*(case When sjd.CurrCode = p.Currency THEN 1 ELSE isnull(sjd.ExchDLine,0) END)  LocalAmount
FROM SEJobMaster jobmaster

inner JOIN SEjobDetail sjd on sjd.TransNumber=jobmaster.TransNumber
inner join Charges charg on charg.CharCode=sjd.CharCode
inner JOIN SEMoreDetails semore on semore.TransNumber=jobmaster.TransNumber  
left join Customers cust on cust.CustCode=sjd.CustomerCode
left JOIN HBLMaster hbl on hbl.TransNumber=jobmaster.TransNumber  
left JOIN Vessel vsl on vsl.VesselCode=jobmaster.vesselcode  
left JOIN CommonCoding cns on cns.CommonCode=semore.ConsigneeCode 
left join CommonCoding ship on ship.CommonCode=semore.ShipperCode
CROSS JOIN parafile p 
where  sjd.RecvAmount>0 
GO

