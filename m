From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: net-2.6.25 is no more...
Date: Wed, 30 Jan 2008 20:16:02 +0100
Message-ID: <47A0CCF2.9080404@fr.ibm.com>
References: <20080129.212216.186173371.davem@davemloft.net> <47A03D4D.5090301@fr.ibm.com> <20080130.054807.182676684.davem@davemloft.net> <47A0B62D.3080005@fr.ibm.com> <20080130182918.GC1819@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:64202 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181AbYA3TUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 14:20:36 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0UJKXVL307248
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 19:20:33 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0UJKXrN4874488
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 19:20:33 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0UJKWrK024198
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 19:20:32 GMT
In-Reply-To: <20080130182918.GC1819@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnaldo Carvalho de Melo wrote:
> Em Wed, Jan 30, 2008 at 06:38:53PM +0100, Daniel Lezcano escreveu:
>> David Miller wrote:
>>> From: Daniel Lezcano <dlezcano@fr.ibm.com>
>>> Date: Wed, 30 Jan 2008 10:03:09 +0100
>>>
>>>> David Miller wrote:
>>>>> Now that the bulk has been merged over and we are
>>>>> actively working alongside Linus's tree I have moved
>>>>> all current patch applying to net-2.6 instead of net-2.6.25,
>>>>> so the current tree to use is:
>>>>>
>>>>> 	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
>>>> This tree is for fixes only, right ? or shall we send enhancement patches 
>>>> to net-2.6 until net-2.6.26 appears ?
>>> The latter.
>> What will happen to the patches sent to net-2.6.25 a few days ago during 
>> the merge ? Should I resend them against net-2.6 ?
> 
> They are probably in net-2.6 already, have you checked? I checked and a
> fix I sent that was not yet merged by Linus is there, in net-2.6.

I checked net-2.6, but unfortunately they are not in. I sent two 
compilation fix error and a subset of the netns ipv6 routing.
