From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Thu, 18 Dec 2008 22:49:05 +0000
Message-ID: <20081218224905.2bc81664@lxorguk.ukuu.org.uk>
References: <1229638581.3726.546.camel@calx>
	<E1LDRbc-0000Ro-1j@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com (Matt Mackall), davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:47868 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751339AbYLRWtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 17:49:18 -0500
In-Reply-To: <E1LDRbc-0000Ro-1j@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Dec 2008 09:44:32 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Matt Mackall <mpm@selenic.com> wrote:
> > These debug messages are uninformative and extremely alarming. Rather
> > than reporting a peer as a treacherous attacker, report it more
> > correctly as simply broken. 
> 
> What's next, you're going to remove "printer on fire" as well?
> This message has been there for eons and is part of Linux lore.

It was changed. The printer on fire ? bit was adjusted to make it clear
because the original message *did* confuse and worry a few people.

IMHO Matt is right on this.

Alan
