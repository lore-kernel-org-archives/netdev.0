From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: port bound SAs
Date: Fri, 30 Jan 2009 17:30:48 +1100
Message-ID: <20090130063048.GA4702@gondor.apana.org.au>
References: <BB7E16A14DE689469A181EC770AFBF4D02A7775E@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: Paul Moore <paul.moore@centrify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43732 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751092AbZA3Ga7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 01:30:59 -0500
Content-Disposition: inline
In-Reply-To: <BB7E16A14DE689469A181EC770AFBF4D02A7775E@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore <paul.moore@centrify.com> wrote:
> aha - so with racoon (which uses pfkey) I cannot make this work

Either fix racoon to use xfrm or go with a properly maintained
key manager like one of the *swans.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
