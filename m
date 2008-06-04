From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] [XFRM] xfrm_algo: correct usage of RIPEMD-160
Date: Wed, 04 Jun 2008 12:05:03 -0700 (PDT)
Message-ID: <20080604.120503.207001089.davem@davemloft.net>
References: <1212399189188-git-send-email-rueegsegger@swiss-it.ch>
	<12123991893044-git-send-email-rueegsegger@swiss-it.ch>
	<20080602104107.GA22943@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rueegsegger@swiss-it.ch, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20080602104107.GA22943@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 2 Jun 2008 20:41:07 +1000

> On Mon, Jun 02, 2008 at 11:33:09AM +0200, Adrian-Ken Rueegsegger wrote:
> > This patch fixes the usage of RIPEMD-160 in xfrm_algo which in turn
> > allows hmac(rmd160) to be used as authentication mechanism in IPsec
> > ESP and AH (see RFC 2857).
> > 
> > Signed-off-by: Adrian-Ken Rueegsegger <rueegsegger@swiss-it.ch>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks everyone.
