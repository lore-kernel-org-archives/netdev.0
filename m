From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net sched: make pedit check for clones
 instead
Date: Mon, 07 Jun 2010 01:09:58 -0700 (PDT)
Message-ID: <20100607.010958.149821476.davem@davemloft.net>
References: <1275655386.3445.62.camel@bigi>
	<20100604130511.GA10925@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jpirko@redhat.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54539
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755444Ab0FGIJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 04:09:48 -0400
In-Reply-To: <20100604130511.GA10925@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 4 Jun 2010 23:05:11 +1000

> On Fri, Jun 04, 2010 at 08:43:06AM -0400, jamal wrote:
>> And here's the second one. I noticed Changli's changes are not yet in
>> net-next. I will wait for that change to propagate and then send the
>> fix to pedit that i discussed with Herbert.
> 
> Thanks Jamal!
> 
> BTW, I think this patch should go in first (before the one that
> removes the OK2MUNGE setting) to be on the safe side.

I applied them this way to net-next-2.6, thanks!
