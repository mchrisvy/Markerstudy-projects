select
case 
	when Valuebuckets between 0 and 0.637560927182563 then 1
	when Valuebuckets between 0.637560927182564 and 1.0041764478748 then 2
	when Valuebuckets between 1.0041764478749 and 1.39276284881945 then 3
	when Valuebuckets between 1.39276284881946 and 1.79666521382875 then 4
	when Valuebuckets between 1.79666521382876 and 2.29157538130934 then 5
	when Valuebuckets between 2.29157538130935 and 2.83432879462987 then 6
	when Valuebuckets between 2.83432879462988 and 3.47517399594557 then 7
	when Valuebuckets between 3.47517399594558 and 4.19382794433251 then 8
	when Valuebuckets between 4.19382794433252 and 5.00494807366862 then 9
	when Valuebuckets between 5.00494807366863 and 6.09476145033762 then 10
	when Valuebuckets between 6.09476145033763 and 7.38083627847549 then 11
	when Valuebuckets between 7.3808362784755 and 9.0654772156146 then 12
	when Valuebuckets between 9.0654772156147 and 11.2075502964765 then 13
	when Valuebuckets between 11.2075502964766 and 14.7202192533628 then 14
	when Valuebuckets between 14.7202192533628 and 999999 then 15
end as bandings
,CEILING(((((FLOOR(DATEDIFF(day, z.Proposer_DOB, y.Policy_SoldDate)/30)
    * (SUBSTRING(RIGHT(y.Proposer_Postcode, 3),1,1)+10)
    * (ASCII(SUBSTRING(RIGHT(y.Proposer_Postcode, 3),2,1))-64)
    * (ASCII(SUBSTRING(RIGHT(y.Proposer_Postcode, 3),3,1))-64))
    * 25214903917+11) % 281474976710655))*360/281474976710655)  as RandomNumber
,case when ( CEILING(((((FLOOR(DATEDIFF(day, z.Proposer_DOB, y.Policy_SoldDate)/30)
    * (SUBSTRING(RIGHT(y.Proposer_Postcode, 3),1,1)+10)
    * (ASCII(SUBSTRING(RIGHT(y.Proposer_Postcode, 3),2,1))-64)
    * (ASCII(SUBSTRING(RIGHT(y.Proposer_Postcode, 3),3,1))-64))
    * 25214903917+11) % 281474976710655))*360/281474976710655) between 1 and 60 ) 
	OR ( CEILING(((((FLOOR(DATEDIFF(day, z.Proposer_DOB, y.Policy_SoldDate)/30)
    * (SUBSTRING(RIGHT(y.Proposer_Postcode, 3),1,1)+10)
    * (ASCII(SUBSTRING(RIGHT(y.Proposer_Postcode, 3),2,1))-64)
    * (ASCII(SUBSTRING(RIGHT(y.Proposer_Postcode, 3),3,1))-64))
    * 25214903917+11) % 281474976710655))*360/281474976710655) between 121 and 180 ) 
	OR ( CEILING(((((FLOOR(DATEDIFF(day, z.Proposer_DOB, y.Policy_SoldDate)/30)
    * (SUBSTRING(RIGHT(y.Proposer_Postcode, 3),1,1)+10)
    * (ASCII(SUBSTRING(RIGHT(y.Proposer_Postcode, 3),2,1))-64)
    * (ASCII(SUBSTRING(RIGHT(y.Proposer_Postcode, 3),3,1))-64))
    * 25214903917+11) % 281474976710655))*360/281474976710655) between 241 and 300 ) then 'Trial A'
	WHEN ( CEILING(((((FLOOR(DATEDIFF(day, z.Proposer_DOB, y.Policy_SoldDate)/30)
    * (SUBSTRING(RIGHT(y.Proposer_Postcode, 3),1,1)+10)
    * (ASCII(SUBSTRING(RIGHT(y.Proposer_Postcode, 3),2,1))-64)
    * (ASCII(SUBSTRING(RIGHT(y.Proposer_Postcode, 3),3,1))-64))
    * 25214903917+11) % 281474976710655))*360/281474976710655) IS NULL ) then '>:('
	else 'Trial B' end as DepositTrial
	
,x.valuebuckets
,y.Policy_Reference

,z.Policy_InceptionDate
,z.Policy_QuoteDate
,z.Proposer_DOB
, y.Policy_SoldDate
,y.Proposer_Postcode


,y.Price_IPPWithIRI
,y.Price_NWP
,y.Policy_SoldFlag
,y.Policy_Product
,y.Policy_SoldDate
,y.Policy_ClassOfUse
,y.KPI_FinancedFlag
,y.KPI_DebtSeverity
,y.KPI_CancellationFlag
,y.KPI_DebtFlag
,y.Policy_SoldYearMonth
,y.policy_eventtype
,y.policy_source
,case when x.Policy_SoldDate>= '2023-05-23' then 'post' else 'pre' end as change
,y.Policy_Underwriter

from Pricing_DB.Pricing.Van_DebtBandingsCalculator_Current x
left join Pricing_DataMart.Pricing.CDLRadarSales y
	on x.policy_reference = y.Policy_Reference
LEFT JOIN Pricing_DataMart.Pricing.CDLRadarClicks z --joined to clicks in case you want to see which trial group they were in when sold
	on x.Policy_Reference = z.Policy_Reference
where x.policy_product = 'van'
and y.Policy_SoldDate >= '2023-05-24' --went live : 2023-05-23
and y.policy_schemecode != 'NA'
and x.policy_eventtype = 'NB'
and y.Policy_EventType = 'NB'
and y.kpi_financedflag = 1
and x.kpi_financedflag = 1
and x.enrichment_Delphi is not null