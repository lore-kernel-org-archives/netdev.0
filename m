From: Andi Kleen <andi@firstfloor.org>
Subject: Re: UDP path MTU discovery
Date: Thu, 1 Apr 2010 02:57:12 +0200
Message-ID: <20100401005712.GA20695@one.firstfloor.org>
References: <1269561751.2891.8.camel@ilion> <20100325.202424.201654947.davem@davemloft.net> <87bpe825z2.fsf@basil.nowhere.org> <1270079864.2389.48.camel@ilion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Glen Turner <gdt@gdt.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:53920 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757179Ab0DAA5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 20:57:13 -0400
Content-Disposition: inline
In-Reply-To: <1270079864.2389.48.camel@ilion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Seems like a big hole not considered by the IPv6 designers?
> 
> Yeah. The sockets API for IPv6 required an additional feature that
> the IETF did not foresee.

Linux (or in this concrete case ANK) did foresee it.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
