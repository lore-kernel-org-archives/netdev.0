From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH 02/11] crypto: Use scatterwalk_crypto_chain
Date: Thu, 2 Dec 2010 14:48:30 +0800
Message-ID: <20101202064830.GA22751@gondor.apana.org.au>
References: <20101122102455.GC1868@secunet.com> <20101122102654.GE1868@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andreas Gruenbacher <agruen@suse.de>,
	Alex Badea <abadea@ixiacom.com>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101122102654.GE1868@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 22, 2010 at 11:26:54AM +0100, Steffen Klassert wrote:
> Use scatterwalk_crypto_chain in favor of locally defined chaining functions.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

I've applied patches 1&2 since they're logically separate from the
rest of the series and make sense on their own.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
