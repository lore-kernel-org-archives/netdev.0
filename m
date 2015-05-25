From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD
 interface
Date: Mon, 25 May 2015 19:53:41 +0800
Message-ID: <20150525115341.GA30627@gondor.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
 <3847514.ujeNcPGtgS@tachyon.chronox.de>
 <20150525102021.GA30038@gondor.apana.org.au>
 <3817112.GjAvZ3MSSX@tachyon.chronox.de>
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
In-Reply-To: <3817112.GjAvZ3MSSX@tachyon.chronox.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 25, 2015 at 01:50:55PM +0200, Stephan Mueller wrote:
>
> When you have my code local, simply execute libkcapi/test/kcapi -y twice or 
> three times. That triggered the crash.

Aha that's what I was missing.  I'll look into the crash.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
