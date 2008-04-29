From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC XFRM]: esp: fix scatterlist of out bounds access with crypto_eseqiv
Date: Tue, 29 Apr 2008 22:45:03 +0800
Message-ID: <20080429144503.GA21238@gondor.apana.org.au>
References: <48161D99.5070303@trash.net> <20080429014107.GA16700@gondor.apana.org.au> <4816AD93.5090404@trash.net> <20080429135932.GA20790@gondor.apana.org.au> <20080429142144.GB16068@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, linux-crypto@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43954 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750837AbYD2OpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 10:45:09 -0400
Content-Disposition: inline
In-Reply-To: <20080429142144.GB16068@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2008 at 06:21:44PM +0400, Evgeniy Polyakov wrote:
> 
> Hey, it works :))
> Just not always, which is great at attracting Patrick and problems.

I was more commenting on the bugs in the crypto layer that breaks
hifn rather than the hifn driver itself :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
