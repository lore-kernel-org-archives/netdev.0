From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: linux-next: manual merge of the crypto tree with the net-next
 tree
Date: Wed, 6 Feb 2013 13:45:57 +0800
Message-ID: <20130206054557.GA3815@gondor.apana.org.au>
References: <20130206132011.9084f982f783cd9d298f187d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Julia Lawall <Julia.Lawall@lip6.fr>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130206132011.9084f982f783cd9d298f187d@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 06, 2013 at 01:20:11PM +1100, Stephen Rothwell wrote:
> Hi Herbert,
> 
> Today's linux-next merge of the crypto tree got a conflict in
> crypto/ctr.c between commit 69d3150cfc20 ("crypto: ctr - make rfc3686
> asynchronous block cipher") from the net-next tree and commit
> 3e8afe35c36f ("crypto: use ERR_CAST") from the crypto tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Looks good.  Thanks Stephen!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
