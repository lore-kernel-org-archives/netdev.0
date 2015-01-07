From: Andre Tomt <andre@tomt.net>
Subject: Re: REGRESSION in nfnetlink on 3.18.x (bisected)
Date: Wed, 07 Jan 2015 23:03:10 +0100
Message-ID: <54ADAD1E.3060101@tomt.net>
References: <5496075F.3060204@tomt.net> <20141222115607.GA4961@salvia> <5498A7DF.6040903@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.ugh.no ([178.79.162.34]:47847 "EHLO mail1.ugh.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754767AbbAGWDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2015 17:03:12 -0500
In-Reply-To: <5498A7DF.6040903@tomt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23. des. 2014 00:23, Andre Tomt wrote:
> On 22. des. 2014 12:56, Pablo Neira Ayuso wrote:
>> Could you give a test to this patch? Thanks.
>>
>
> Initial testing looks good with this patch applied on top of 3.18.1
> I will give it a spin on some more systems tomorrow.

No news is good news :-)

~10 3.18.x systems in various roles have had this fix for two weeks with 
no issues.
