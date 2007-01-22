From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] tcp_output: Re: rare bad TCP checksum with 2.6.19?
Date: Mon, 22 Jan 2007 09:03:45 +0100
Message-ID: <20070122080345.GA2079@ff.dom.local>
References: <20070119110641.GA3135@ff.dom.local> <45B0C581.1020805@tls.msk.ru> <20070119140820.GA3424@ff.dom.local> <20070122071303.GB1634@ff.dom.local> <45B46576.1070104@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:34698 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750778AbXAVIBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 03:01:25 -0500
To: Michael Tokarev <mjt@tls.msk.ru>
Content-Disposition: inline
In-Reply-To: <45B46576.1070104@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 22, 2007 at 10:19:18AM +0300, Michael Tokarev wrote:
...
> I was only running tcpdump - yes, it was running almost the
> whole day, with different options.  I did almost nothing.
> 
> You over-estimate my contribution, really ;)
> 
> The very good thing is that this bug is now found, and *that*
> is what matters.

But if you consider that 2.6.19 isn't so fresh now
and the bug was in a very often used place and it for
sure had to disturb many times in many places, so I'm
not sure, if without your doing "almost nothing", this
bug would be diagnosed in the next year or two, really.

Jarek P. 
