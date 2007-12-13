From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Fix reversed ICMP6 policy check
Date: Wed, 12 Dec 2007 18:51:16 -0800 (PST)
Message-ID: <20071212.185116.101568793.davem@davemloft.net>
References: <20071212173951.4f1eb99a.akpm@linux-foundation.org>
	<20071213015856.GA32668@gondor.apana.org.au>
	<20071213024918.GA731@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52324
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751880AbXLMCvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 21:51:16 -0500
In-Reply-To: <20071213024918.GA731@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Dec 2007 10:49:18 +0800

> On Thu, Dec 13, 2007 at 09:58:56AM +0800, Herbert Xu wrote:
> >
> > [IPSEC]: Fix reversed ICMP6 policy check
> 
> While that won't crash anymore, it's still logically wrong.
> 
> Here's a more complete fix.

I already applied the first one, please send a relative
fixup which I'll combine as appropriate next rebase.
