From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: use xfrm_addr_cmp() instead of compare addresses
	directly
Date: Mon, 29 Jun 2009 15:57:37 +0800
Message-ID: <20090629075737.GA4827@gondor.apana.org.au>
References: <4A48464D.2010501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36370 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751763AbZF2H5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 03:57:40 -0400
Content-Disposition: inline
In-Reply-To: <4A48464D.2010501@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2009 at 12:42:53PM +0800, Wei Yongjun wrote:
> Clean up to use xfrm_addr_cmp() instead of compare addresses directly.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Looks good to me.  Thanks!

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
