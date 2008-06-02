From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] [XFRM] xfrm_algo: correct usage of RIPEMD-160
Date: Mon, 2 Jun 2008 20:41:07 +1000
Message-ID: <20080602104107.GA22943@gondor.apana.org.au>
References: <1212399189188-git-send-email-rueegsegger@swiss-it.ch> <12123991893044-git-send-email-rueegsegger@swiss-it.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Adrian-Ken Rueegsegger <rueegsegger@swiss-it.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34156 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751577AbYFBKlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 06:41:14 -0400
Content-Disposition: inline
In-Reply-To: <12123991893044-git-send-email-rueegsegger@swiss-it.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 02, 2008 at 11:33:09AM +0200, Adrian-Ken Rueegsegger wrote:
> This patch fixes the usage of RIPEMD-160 in xfrm_algo which in turn
> allows hmac(rmd160) to be used as authentication mechanism in IPsec
> ESP and AH (see RFC 2857).
> 
> Signed-off-by: Adrian-Ken Rueegsegger <rueegsegger@swiss-it.ch>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
