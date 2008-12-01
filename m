From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 5/5] crypto: make struct aead percpu data
Date: Mon, 1 Dec 2008 21:44:48 +0800
Message-ID: <20081201134448.GA21939@gondor.apana.org.au>
References: <20081201071614.GP476@secunet.com> <20081201072043.GU476@secunet.com> <20081201114000.GB20961@gondor.apana.org.au> <20081201133654.GC13998@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35123 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751348AbYLANoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 08:44:54 -0500
Content-Disposition: inline
In-Reply-To: <20081201133654.GC13998@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 02:36:54PM +0100, Steffen Klassert wrote:
>
> I searched for your shash work. Is there already some work in progress
> aside from crc32?

I started on the algorithm conversion but have only made it as far
as null and rmd*.  But it should serve as a good template for doing
the rest.

If you could finish them for me I'd be most grateful :)

I'll push what I've got out now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
