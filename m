From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] xfrm4_beet_input(): fix an if()
Date: Tue, 05 Feb 2008 02:51:58 -0800 (PST)
Message-ID: <20080205.025158.160772590.davem@davemloft.net>
References: <20080202211635.GF9375@cs181133002.pp.htv.fi>
	<20080202222226.GB31388@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59150
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756219AbYBEKva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 05:51:30 -0500
In-Reply-To: <20080202222226.GB31388@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 3 Feb 2008 09:22:26 +1100

> On Sat, Feb 02, 2008 at 11:16:35PM +0200, Adrian Bunk wrote:
> > A bug every C programmer makes at some point in time...
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> Good catch!
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
