From: David Miller <davem@davemloft.net>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 13:31:15 -0700 (PDT)
Message-ID: <20071002.133115.26989635.davem@davemloft.net>
References: <47028DEF.5070009@psc.edu>
	<20071002190742.GC29944@bitmover.com>
	<alpine.LFD.0.999.0710021228540.3579@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lm@bitmover.com, jheffner@psc.edu, herbert@gondor.apana.org.au,
	wscott@bitmover.com, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44444
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753472AbXJBUbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 16:31:15 -0400
In-Reply-To: <alpine.LFD.0.999.0710021228540.3579@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 2 Oct 2007 12:29:50 -0700 (PDT)

> On Tue, 2 Oct 2007, Larry McVoy wrote:
> > 
> > No HP in the mix.  It's got nothing to do with hp, nor to do with rsh, it 
> > has everything to do with the direction the data is flowing.  
> 
> Can you tcpdump both cases and send snippets (both of steady-state, and 
> the initial connect)? 

Another thing I'd like to see is if something more recent than 2.6.18
also reproduces the problem.

It could be just some bug we've fixed in the past year :)
