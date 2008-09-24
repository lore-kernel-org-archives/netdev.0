From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 24 Sep 2008 14:21:38 +0800
Message-ID: <20080924062138.GA6764@gondor.apana.org.au>
References: <20080923133234.GA30370@gondor.apana.org.au> <48D8F337.2050103@iki.fi> <20080924042349.GA5419@gondor.apana.org.au> <48D9CCA3.2040500@iki.fi> <20080924051555.GA6218@gondor.apana.org.au> <48D9D421.9050500@iki.fi> <20080924055550.GA6506@gondor.apana.org.au> <48D9D86E.7020205@iki.fi> <20080924061349.GA6679@gondor.apana.org.au> <48D9DC1A.10903@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52141 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750937AbYIXGVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 02:21:44 -0400
Content-Disposition: inline
In-Reply-To: <48D9DC1A.10903@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2008 at 09:20:10AM +0300, Timo Ter=E4s wrote:
>
> Just saying that the code easily misleads the reader. And in
> this kind of non-obvious places we should have some comments.
> Or make the code more readable by adding the intermediate struct.

=46air enough.  Feel free to reformat the patch and add the struct
to make it more bullet-proof.  I'm sorry I've got some paid work
to do now :)

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
