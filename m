From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Async crypto support in IPsec
Date: Tue, 20 Nov 2007 18:13:42 +0800
Message-ID: <E1IuQ6w-0004Cs-00@gondolin.me.apana.org.au>
References: <BFECAF9E178F144FAEF2BF4CE739C668039A0CD0@exmail1.se.axis.com>
Cc: netdev@vger.kernel.org
To: jesper.bengtsson@axis.com (Jesper Bengtsson)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1525 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755835AbXKTKNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 05:13:49 -0500
In-Reply-To: <BFECAF9E178F144FAEF2BF4CE739C668039A0CD0@exmail1.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Bengtsson <jesper.bengtsson@axis.com> wrote:
>
> The crisv32 crypto accelerator supports hashing and encryption in one
> single operation. Do you have any plans for supporting hashing and
> encryption in one operation?

Absolutely.  Checkout the crypto_aead_* operations and authenc.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
