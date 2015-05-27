From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [v3 PATCH 0/8] crypto: Convert all AEAD users to new interface
Date: Wed, 27 May 2015 11:32:19 +0200
Message-ID: <20150527093218.GD27342@secunet.com>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <20150522082708.GA3507@gondor.apana.org.au>
 <20150527080105.GA26751@gondor.apana.org.au>
 <20150527092533.GC27342@secunet.com>
 <20150527092922.GA28022@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stephan Mueller <smueller@chronox.de>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150527092922.GA28022@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 27, 2015 at 05:29:22PM +0800, Herbert Xu wrote:
> On Wed, May 27, 2015 at 11:25:33AM +0200, Steffen Klassert wrote:
> > 
> > Not sure if I missed something in the flood of patches, but if I
> > apply your v3 patchset on top of the cryptodev tree, it crashes
> > like that buring boot:
> 
> Sorry, I forgot to mention that v3 depends on the series of fixes
> posted just before it (but only to linux-crypto):
> 
> https://www.mail-archive.com/linux-crypto@vger.kernel.org/msg14487.html
> 

OK, I'll try with this.

Thanks!
