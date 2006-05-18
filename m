From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 2/4] myri10ge - Driver header files
Date: Fri, 19 May 2006 01:36:21 +0200
Message-ID: <446D04F5.3080802@myri.com>
References: <20060517220218.GA13411@myri.com>	<20060517220434.GC13411@myri.com> <20060517152817.58a6d8bc.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:13991 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751080AbWERXgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 May 2006 19:36:39 -0400
To: "Randy.Dunlap" <rdunlap@xenotime.net>
In-Reply-To: <20060517152817.58a6d8bc.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy.Dunlap wrote:
>> [PATCH 2/4] myri10ge - Driver header files
>>
>>  myri10ge_mcp.h            |  205 ++++++++++++++++++++++++++++++++++++++++++++++
>>  myri10ge_mcp_gen_header.h |   58 +++++++++++++
>>     
>
> Please use "diffstat -p 1 -w 70" is documented in
> Documentation/SubmittingPatches.
>   

Ok, will do.

>> +/* 16 Bytes */
>>     
> What is 16 bytes here?
>   
>> +struct mcp_slot {
>> +	u16 checksum;
>> +	u16 length;
>> +};
>>     

Looks like I have problems to compute the size of this type.

Thanks,
Brice

