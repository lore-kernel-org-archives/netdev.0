From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v3 PATCH 0/8] crypto: Convert all AEAD users to new interface
Date: Wed, 27 May 2015 17:29:22 +0800
Message-ID: <20150527092922.GA28022@gondor.apana.org.au>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <20150522082708.GA3507@gondor.apana.org.au>
 <20150527080105.GA26751@gondor.apana.org.au>
 <20150527092533.GC27342@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stephan Mueller <smueller@chronox.de>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:52575 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbbE0J31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 05:29:27 -0400
Content-Disposition: inline
In-Reply-To: <20150527092533.GC27342@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2015 at 11:25:33AM +0200, Steffen Klassert wrote:
> 
> Not sure if I missed something in the flood of patches, but if I
> apply your v3 patchset on top of the cryptodev tree, it crashes
> like that buring boot:

Sorry, I forgot to mention that v3 depends on the series of fixes
posted just before it (but only to linux-crypto):

https://www.mail-archive.com/linux-crypto@vger.kernel.org/msg14487.html

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
