From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] tcp_output: Re: rare bad TCP checksum with 2.6.19?
Date: Mon, 22 Jan 2007 09:48:56 +0100
Message-ID: <20070122084856.GB2079@ff.dom.local>
References: <45AE2EDF.4060709@tls.msk.ru> <20070119110641.GA3135@ff.dom.local> <20070119211027.GA16626@gondor.apana.org.au> <20070122065214.GA1634@ff.dom.local> <20070122074557.GA15461@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Tokarev <mjt@tls.msk.ru>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	"David S\. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:60177 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750791AbXAVIqf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 03:46:35 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20070122074557.GA15461@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 22, 2007 at 06:45:57PM +1100, Herbert Xu wrote:
> On Mon, Jan 22, 2007 at 07:52:14AM +0100, Jarek Poplawski wrote:
> >  
> > I was so impressed by the amount of work done by Michael
> > that I magnified his merit and forgot to mention the role
> > of Patrick and Herbert, particularly here:
> 
> You don't need to be so modest!
> 
> While no doubt Patrick helped in tracking this down, my role in
> this thread is solely in adding this bug in the first place :)

Let's be sincere then: I really spend more time on
thinking why, with this hint of yours and the last
summary of Michael, you didn't send this patch yet,
and checking if I don't repeat or appropriate your
work, then on finding the place. My only explanation
was: you were overworked with something else and I'm
sure you think the same, now.

Jarek P.

PS: considering the amount of diplomacy relative to
the size of the patch, I think we would better stop
amuse this list here. 
