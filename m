From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/3] [PPP]: Fix pppol2tp skb bugs
Date: Tue, 18 Sep 2007 20:04:38 +0800
Message-ID: <20070918120438.GA9121@gondor.apana.org.au>
References: <200708281811.34074.toralf.foerster@gmx.de> <46D521BC.1050300@katalix.com> <200708291822.35128.toralf.foerster@gmx.de> <46D69323.3070503@katalix.com> <20070831090625.GA28175@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4970 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755829AbXIRMFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 08:05:50 -0400
Content-Disposition: inline
In-Reply-To: <20070831090625.GA28175@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 05:06:25PM +0800, Herbert Xu wrote:
> 
> I've audited ppp_generic.c and pppoe.c.  I'll do pppol2tp
> tomorrow.

Tomrrow took a while to come :)

Here are the fixes for pppol2tp.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
