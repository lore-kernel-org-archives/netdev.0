From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/8] Bug fixes
Date: Fri, 3 Feb 2017 18:21:13 +0800
Message-ID: <20170203102113.GD2632@gondor.apana.org.au>
References: <cover.1485501428.git.harsh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, hariprasad@chelsio.com,
        netdev@vger.kernel.org, arjun@chelsio.com, atul.gupta@chelsio.com
To: Harsh Jain <harsh@chelsio.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1485501428.git.harsh@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 27, 2017 at 04:09:04PM +0530, Harsh Jain wrote:
> This patch series is based on Herbert's cryptodev-2.6 tree and depends on 
> patch series "Bug Fixes for 4.10". It includes Bug Fixes.
> 
> Atul Gupta (2)
>   crypto:chcr-Change flow IDs
>   crypto:chcr- Fix wrong typecasting
> Harsh Jain (8):
>   crypto:chcr- Fix key length for RFC4106
>   crypto:chcr-fix itnull.cocci warnings
>   crypto:chcr- Use cipher instead of Block Cipher in gcm setkey
>   crypto:chcr: Change cra_flags for cipher algos
>   crypto:chcr- Change algo priority
>   crypto:chcr-Fix Smatch Complaint

All applied.  Thanks.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
