From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove unused parameter of xfrm_gen_index()
Date: Wed, 12 Nov 2008 23:28:25 -0800 (PST)
Message-ID: <20081112.232825.51533353.davem@davemloft.net>
References: <87zlk5ccpg.fsf@natisbad.org>
	<20081113020102.GA27879@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arno@natisbad.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44970
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751508AbYKMH2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 02:28:25 -0500
In-Reply-To: <20081113020102.GA27879@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Nov 2008 10:01:02 +0800

> On Wed, Nov 12, 2008 at 02:10:03PM +0100, Arnaud Ebalard wrote:
> > Hi David,
> > 
> > In commit 2518c7c2b3d7f0a6b302b4efe17c911f8dd4049f, the last use of
> > xfrm_gen_policy() first argument was removed, but the argument was
> > left behind in the prototype. Patch is against current net-2.6.
> > 
> > Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
> 
> Looks good to me.
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks everyone.
