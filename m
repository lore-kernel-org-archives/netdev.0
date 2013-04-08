From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] crypto: add CMAC support to CryptoAPI
Date: Mon, 8 Apr 2013 17:33:40 +0800
Message-ID: <20130408093340.GA18594@gondor.apana.org.au>
References: <20130408074844.6866.90093.stgit@localhost6.localdomain6>
 <20130408082416.GW21448@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jussi Kivilinna <jussi.kivilinna@iki.fi>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	Tom St Denis <tstdenis@elliptictech.com>,
	"David S. Miller" <davem@davemloft.net>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130408082416.GW21448@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 08, 2013 at 10:24:16AM +0200, Steffen Klassert wrote:
> On Mon, Apr 08, 2013 at 10:48:44AM +0300, Jussi Kivilinna wrote:
> > Patch adds support for NIST recommended block cipher mode CMAC to CryptoAPI.
> > 
> > This work is based on Tom St Denis' earlier patch,
> >  http://marc.info/?l=linux-crypto-vger&m=135877306305466&w=2
> > 
> > Cc: Tom St Denis <tstdenis@elliptictech.com>
> > Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>
> 
> This patch does not apply clean to the ipsec-next tree
> because of some crypto changes I don't have in ipsec-next.
> The IPsec part should apply to the cryptodev tree,
> so it's probaply the best if we route this patchset
> through the cryptodev tree.
> 
> Herbert,
> 
> are you going to take these patches?

Sure I can do that.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
