From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next-2.6] net sched: make pedit check for clones
	instead
Date: Fri, 4 Jun 2010 23:05:11 +1000
Message-ID: <20100604130511.GA10925@gondor.apana.org.au>
References: <1275655386.3445.62.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:59272 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755284Ab0FDNFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 09:05:25 -0400
Content-Disposition: inline
In-Reply-To: <1275655386.3445.62.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 04, 2010 at 08:43:06AM -0400, jamal wrote:
> And here's the second one. I noticed Changli's changes are not yet in
> net-next. I will wait for that change to propagate and then send the
> fix to pedit that i discussed with Herbert.

Thanks Jamal!

BTW, I think this patch should go in first (before the one that
removes the OK2MUNGE setting) to be on the safe side.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
