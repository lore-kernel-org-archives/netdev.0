From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] tcp_output: Re: rare bad TCP checksum with 2.6.19?
Date: Fri, 19 Jan 2007 15:08:20 +0100
Message-ID: <20070119140820.GA3424@ff.dom.local>
References: <20070119110641.GA3135@ff.dom.local> <45B0C581.1020805@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:56081 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965158AbXASOGH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 09:06:07 -0500
To: Michael Tokarev <mjt@tls.msk.ru>
Content-Disposition: inline
In-Reply-To: <45B0C581.1020805@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 19, 2007 at 04:20:01PM +0300, Michael Tokarev wrote:
...
> Well..  I just tried it - with this patch applied, no more bad checksums
> are shown.  Tried from the network that triggers it most reliable - and
> wasn't able to reproduce the bad behavior.
> 
> I'm running a tcpdump right now, and so far it only captured a few bad-cksum
> packets from other hosts (which are also running 2.6.19 ;)
> 
> Thanks Jarek!

You are welcome! But you probably didn't read this with
attention: if it works, you should thank mainly to that
other guy...

Btw. I can't remember I've seen such ferocious testing
ever!

Cheers,
Jarek P.
