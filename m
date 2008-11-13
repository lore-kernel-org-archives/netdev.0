From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Remove unused parameter of xfrm_gen_index()
Date: Thu, 13 Nov 2008 10:01:02 +0800
Message-ID: <20081113020102.GA27879@gondor.apana.org.au>
References: <87zlk5ccpg.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47473 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752343AbYKMCBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 21:01:12 -0500
Content-Disposition: inline
In-Reply-To: <87zlk5ccpg.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2008 at 02:10:03PM +0100, Arnaud Ebalard wrote:
> Hi David,
> 
> In commit 2518c7c2b3d7f0a6b302b4efe17c911f8dd4049f, the last use of
> xfrm_gen_policy() first argument was removed, but the argument was
> left behind in the prototype. Patch is against current net-2.6.
> 
> Signed-off-by: Arnaud Ebalard <arno@natisbad.org>

Looks good to me.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
