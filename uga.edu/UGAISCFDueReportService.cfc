<!---
UGAISCFDueReportService.cfc
--->

<cfcomponent extends="AbstractReportService">
	<cffunction name="getReportServiceType" access="package" returntype="ReportServiceType">
		<cfscript>
			reportServiceType = createObject("component", "ReportServiceType");
			reportServiceType.ID = "UGAISCFDueReportService";
			reportServiceType.reportGroup = "UGA Standard Reports";
			reportServiceType.reportName = "Fees Due Report";
			reportServiceType.reportDesc = "Shows the records of upcoming or past due ISC fees.";
			reportServiceType.setIndividual = false;
			reportServiceType.options = getOptions();
			reportServiceType.outputXLS = true;    
			reportServiceType.statistical = true;
		</cfscript>
		<cfreturn reportServiceType>
       </cffunction>     

	<cffunction name="getDataset" access="private" returntype="string">
		<cfargument name="reportObject" type="ReportObject" required="true">		
		<cfargument name="options" type="array" required="true">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
        
		<cfscript>
			today = CreateDate(Year(Now()), Month(Now()), Day(Now()));
			startDateValue = getOptionValueByGroup("rangeBeginDate", options, "#today#");
			endDateValue = getOptionValueByGroup("rangeEndDate", options, "#today#");
			if( IsDate(startDateValue) is false )
				startDateValue = today;
			if( IsDate(endDateValue) is false )
				endDateValue = today;
		</cfscript>
		
		<cftry>
			<!--- 1:FeeType,2:FundingLevel,3:DueDate,4:AmountDue,5:PaidDate,6:AmountRecieved,7:Payor--->
			<cfquery name="ISCFeeScholars">
				SELECT DISTINCT 
					jbInternational.idnumber AS [sunapsisid]
					,firstname AS [FirstName]
					,lastname AS [LastName]
					,CustomField1 AS [FeeType]
					,CustomField2 AS [FundingLevel]
					,CustomField3 AS [DueDate]
					,CustomField4 AS [AmountDue]
					,CustomField5 AS [PaidDate]
					,CustomField6 AS [AmountReceived]
					,CustomField7 AS [FeePaidBy]
					,CustomField8 AS [Comments]

				FROM
					jbInternational
					INNER JOIN jbCustomFields3 [iscf custom fee table] ON [iscf custom fee table].idnumber = jbInternational.idnumber

				WHERE 
					CONVERT(datetime, CustomField3) > <cfqueryparam cfsqltype="cf_sql_date" value="#startDateValue#">
					AND CONVERT(datetime, CustomField3) < <cfqueryparam cfsqltype="cf_sql_date" value="#endDateValue#">
					AND CustomField6 < CustomField4

				ORDER BY [DueDate]
				FOR XML PATH
			</cfquery>
			
			<cfcatch>
				<cfset time= DateTimeFormat(Now(), "mm/dd/yyyy hh:nn:ss aaa") >
				<cffile action = "write"    file = "c:\logs\iscf.html" output="#time#">
				<cfdump var="#cfcatch#" output="c:\logs\iscf.html" format="html">
			</cfcatch>
		</cftry>
			<cfscript>
				reportResult = getXMLFromQuery(ISCFeeScholars);
			</cfscript>
		<cfreturn reportResult>
	</cffunction>
	
	<cffunction name="getOptions" access="private" returntype="array">	
		<cfscript>
			options = ArrayNew(1);
			
			dateOptionA = createObject("component", "Option");
			dateOptionA.code = "";
			dateOptionA.description = "-";
			dateOptionA.group = "rangeBeginDate";
			dateOptionA.groupDesc = "Range Begin Date (mm/dd/yyyy)";
			ArrayAppend(options, dateOptionA);
			
			dateOptionB = createObject("component", "Option");
			dateOptionB.code = "";
			dateOptionB.description = "-";
			dateOptionB.group = "rangeEndDate";
			dateOptionB.groupDesc = "Range End Date (mm/dd/yyyy)";
			ArrayAppend(options, dateOptionB);
		</cfscript>
		<cfreturn options>
	</cffunction>

</cfcomponent>
