From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [CRYPTO] users: Fix up scatterlist conversion
 errors
Date: Sat, 27 Oct 2007 00:52:19 -0700 (PDT)
Message-ID: <20071027.005219.216043460.davem@davemloft.net>
References: <20071026145905.GA13850@gondor.apana.org.au>
	<E1IlQfN-0003cW-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <E1IlQfN-0003cW-00@gondolin.me.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 26 Oct 2007 23:00:05 +0800

> [CRYPTO] users: Fix up scatterlist conversion errors
> 
> This patch fixes the errors made in the users of the crypto layer during
> the sg_init_table conversion.  It also adds a few conversions that were
> missing altogether.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks Herbert!
