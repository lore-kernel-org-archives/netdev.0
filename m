From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [CRYPTO] tcrypt: Move sg_init_table out of timing
 loops
Date: Sat, 27 Oct 2007 00:51:30 -0700 (PDT)
Message-ID: <20071027.005130.156717130.davem@davemloft.net>
References: <20071026145905.GA13850@gondor.apana.org.au>
	<E1IlQfM-0003cO-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <E1IlQfM-0003cO-00@gondolin.me.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 26 Oct 2007 23:00:04 +0800

> [CRYPTO] tcrypt: Move sg_init_table out of timing loops
> 
> This patch moves the sg_init_table out of the timing loops for hash
> algorithms so that it doesn't impact on the speed test results.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
