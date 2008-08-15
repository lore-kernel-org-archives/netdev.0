From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression	for	iptables nat routing
Date: Fri, 15 Aug 2008 16:17:35 +1000
Message-ID: <E1KTscx-0001sA-00@gondolin.me.apana.org.au>
References: <1218779373.23510.25.camel@2710p.home>
Cc: herbert@gondor.apana.org.au, kaber@trash.net, davem@davemloft.net,
	akpm@linux-foundation.org, buytenh@marvell.com,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: alex.williamson@hp.com (Alex Williamson)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42251 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750920AbYHOGRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 02:17:47 -0400
In-Reply-To: <1218779373.23510.25.camel@2710p.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex Williamson <alex.williamson@hp.com> wrote:
> 
> Nope, that doesn't fix it.  NAT'd throughput remains about the same.

Please take the raw packet dump on lo then.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
