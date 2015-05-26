From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/7] esp6: Switch to new AEAD interface
Date: Tue, 26 May 2015 15:21:52 +0800
Message-ID: <20150526072152.GA6407@gondor.apana.org.au>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <2066513.Bca9qAkvxD@tauon>
 <20150522071923.GA2777@gondor.apana.org.au>
 <2306681.gksi6E3i3N@tachyon.chronox.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2306681.gksi6E3i3N@tachyon.chronox.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 26, 2015 at 08:39:56AM +0200, Stephan Mueller wrote:
> 
> May I also ask where I can find the generated IV when using rfc4106(gcm(aes))? 

You need to use the IV generator, seqniv(rfc4106(gcm(aes)))

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
