From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net - Add AF_ALG macros
Date: Thu, 04 Nov 2010 12:22:35 -0700 (PDT)
Message-ID: <20101104.122235.189710188.davem@davemloft.net>
References: <20101104173456.GA1321@gondor.apana.org.au>
	<E1PE3jX-0000M8-FP@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <E1PE3jX-0000M8-FP@gondolin.me.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 04 Nov 2010 12:36:19 -0500

> net - Add AF_ALG macros
> 
> This patch adds the socket family/level macros for the yet-to-be-born
> AF_ALG family.  The AF_ALG family provides the user-space interface
> for the kernel crypto API.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: David S. Miller <davem@davemloft.net>
