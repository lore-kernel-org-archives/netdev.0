From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tc: remove unused redirect ttl
Date: Sat, 02 May 2015 00:23:07 -0400 (EDT)
Message-ID: <20150502.002307.2215663290699992792.davem@davemloft.net>
References: <CAHA+R7NOr4aQMXfC7yMuzy3dKRTJB9AYg5HMD2zVXLHM5iZYyw@mail.gmail.com>
	<20150501.194821.135988326109135305.davem@davemloft.net>
	<55444165.3050401@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, sergei.shtylyov@cogentembedded.com,
	jhs@mojatatu.com, daniel@iogearbox.net, fw@strlen.de,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42033 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbbEBEXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 00:23:11 -0400
In-Reply-To: <55444165.3050401@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri, 01 May 2015 20:15:49 -0700

> On 5/1/15 4:48 PM, David Miller wrote:
>> From: Cong Wang <cwang@twopensource.com>
>> Date: Fri, 1 May 2015 13:33:28 -0700
>>
>>> Quote from Documentation/SubmittingPatches:
>>>
>>> "
>>> The "from" line must be the very first line in the message body,
>>> and has the form:
>>>
>>>          From: Original Author <author@example.com>
>>>
>>> The "from" line specifies who will be credited as the author of the
>>> patch in the permanent changelog.  If the "from" line is missing,
>>> then the "From:" line from the email header will be used to determine
>>> the patch author in the changelog.
>>> "
>>>
>>> You should take a look at how Andrew Morton works
>>> when he fixes minor things, I am sure he fixes much
>>> more than you do.
>>
>> +1
>>
> 
> Dave, please help me understand the rules here.

If Jamal wrote the patch and you made some modifications it's
still his his patch so he gets authorship.

Who are you, Napoleon?
