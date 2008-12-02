From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 0/5] IPsec parallelization
Date: Tue, 2 Dec 2008 18:37:23 +0800
Message-ID: <20081202103723.GA30976@gondor.apana.org.au>
References: <20081201071614.GP476@secunet.com> <20081201084902.GA19904@gondor.apana.org.au> <20081201.022929.253639406.davem@davemloft.net> <20081201111501.GA20650@gondor.apana.org.au> <20081202075804.GD13998@secunet.com> <20081202081948.GA30063@gondor.apana.org.au> <20081202084419.GF13998@secunet.com> <20081202085325.GA30353@gondor.apana.org.au> <20081202093911.GH13998@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37654 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752614AbYLBKhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 05:37:31 -0500
Content-Disposition: inline
In-Reply-To: <20081202093911.GH13998@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 02, 2008 at 10:39:11AM +0100, Steffen Klassert wrote:
>
> I would not mind to move the padata hooks to the crypto layer.
> 
> But what's with the interface? Should it be moved to the crypto
> layer too? I'm not sure, but perhaps it could find users beyond
> the crypto layer.

As I said I have no objections to the padata stuff itself so
I don't really mind either way.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
