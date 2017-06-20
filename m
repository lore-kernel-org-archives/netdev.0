From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/9] Bug fixes and ctr mode of operation
Date: Tue, 20 Jun 2017 11:41:33 +0800
Message-ID: <20170620034133.GH17764@gondor.apana.org.au>
References: <cover.1497506936.git.harsh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
        ganeshgr@chelsio.com
To: Harsh Jain <harsh@chelsio.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1497506936.git.harsh@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 15, 2017 at 12:43:38PM +0530, Harsh Jain wrote:
> This series is based on cryptodev2.6 tree and includes bug fix ,ctr(aes), rfc3686(ctr(aes)) algo.
> 
> Harsh Jain (7):
>   crypto: chcr - Pass lcb bit setting to firmware
>   crypto: chcr - Set fallback key
>   crypto: chcr - Return correct error code
>   crypto: chcr - Avoid changing request structure
>   crypto:chcr - Add ctr mode and process large sg entries for cipher
>   MAINTAINERS:Add maintainer for chelsio crypto driver
>   crypto: chcr - Ensure Destination sg entry size less than      2k
> Atul Gupta (2):
>   chcr - Add debug counters
>   crypto: chcr - Select device in Round Robin fashion

All applied.  Thanks.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
