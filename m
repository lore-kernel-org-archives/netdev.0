From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 12:29:50 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0710021228540.3579@woody.linux-foundation.org>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au>
 <20071002150935.GC17418@bitmover.com> <47028DEF.5070009@psc.edu>
 <20071002190742.GC29944@bitmover.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: John Heffner <jheffner@psc.edu>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: Larry McVoy <lm@bitmover.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59391 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756037AbXJBTam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 15:30:42 -0400
In-Reply-To: <20071002190742.GC29944@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 2 Oct 2007, Larry McVoy wrote:
> 
> No HP in the mix.  It's got nothing to do with hp, nor to do with rsh, it 
> has everything to do with the direction the data is flowing.  

Can you tcpdump both cases and send snippets (both of steady-state, and 
the initial connect)? 

		Linus
