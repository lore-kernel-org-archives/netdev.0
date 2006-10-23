From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4][CRYPTO][IPsec] pass the flags to the internal tfm allocation
Date: Mon, 23 Oct 2006 20:34:35 +1000
Message-ID: <20061023103435.GA2415@gondor.apana.org.au>
References: <20061018112606.b4f40c18.kazunori@miyazawa.org> <20061022045356.GA12203@gondor.apana.org.au> <20061023190839.37580ede.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54795 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751881AbWJWKfZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 06:35:25 -0400
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <20061023190839.37580ede.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 23, 2006 at 07:08:39PM +0900, Kazunori MIYAZAWA wrote:
>
> I send the patch which does not use the CBC mode.
> I chose the short term solution and copied the function.

Thanks Miyazawa-san!

> This patch does not need the patch of [PATCH 1/4].
> 
> Should I re-send [PATCH 3/4] and [PATCH 4/4]?
> Or could you re-use them?

They should be fine.  I'll let you know if I run into any problems
applying them :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
