From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] xfrm_user: verify policy direction at
	XFRM_MSG_POLEXPIRE handler
Date: Wed, 31 Mar 2010 18:54:27 +0800
Message-ID: <20100331105427.GB12845@gondor.apana.org.au>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-4-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:39706 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755081Ab0CaKy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 06:54:29 -0400
Content-Disposition: inline
In-Reply-To: <1270030626-16687-4-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 01:17:04PM +0300, Timo Teras wrote:
> Add missing check for policy direction verification. This is
> especially important since without this xfrm_user may end up
> deleting per-socket policy which is not allowed.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
