From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: net-2.6.25 is no more...
Date: Wed, 30 Jan 2008 16:29:18 -0200
Message-ID: <20080130182918.GC1819@ghostprotocols.net>
References: <20080129.212216.186173371.davem@davemloft.net> <47A03D4D.5090301@fr.ibm.com> <20080130.054807.182676684.davem@davemloft.net> <47A0B62D.3080005@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56822 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750778AbYA3S3q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 13:29:46 -0500
Content-Disposition: inline
In-Reply-To: <47A0B62D.3080005@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Jan 30, 2008 at 06:38:53PM +0100, Daniel Lezcano escreveu:
> David Miller wrote:
>> From: Daniel Lezcano <dlezcano@fr.ibm.com>
>> Date: Wed, 30 Jan 2008 10:03:09 +0100
>>
>>> David Miller wrote:
>>>> Now that the bulk has been merged over and we are
>>>> actively working alongside Linus's tree I have moved
>>>> all current patch applying to net-2.6 instead of net-2.6.25,
>>>> so the current tree to use is:
>>>>
>>>> 	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
>>> This tree is for fixes only, right ? or shall we send enhancement patches 
>>> to net-2.6 until net-2.6.26 appears ?
>>
>> The latter.
>
> What will happen to the patches sent to net-2.6.25 a few days ago during 
> the merge ? Should I resend them against net-2.6 ?

They are probably in net-2.6 already, have you checked? I checked and a
fix I sent that was not yet merged by Linus is there, in net-2.6.

- Arnaldo
