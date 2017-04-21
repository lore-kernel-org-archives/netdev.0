From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/4]  Bug fixes and fallback for AEAD
Date: Fri, 21 Apr 2017 21:14:33 +0800
Message-ID: <20170421131433.GA14803@gondor.apana.org.au>
References: <cover.1491807106.git.harsh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
        atul.gupta@chelsio.com, ganeshgr@chelsio.com
To: Harsh Jain <harsh@chelsio.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1491807106.git.harsh@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 10, 2017 at 06:23:57PM +0530, Harsh Jain wrote:
> This series based on Herbert cryptodev-2.6.
> It includes bug fixes and fallback for AEAD algos.
> 
> Harsh Jain (3):
>   chcr: Increase priority of AEAD algos.
>   chcr:Set hmac_ctrl bit to use HW register HMAC_CFG[456].
>   chcr: Add fallback for AEAD algos
> Atul Gupta (1):
>   chcr: Fix txq ids

All applied.  Thanks.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
