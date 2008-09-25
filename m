From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Thu, 25 Sep 2008 17:49:05 +0800
Message-ID: <20080925094905.GA19180@gondor.apana.org.au>
References: <20080924062138.GA6764@gondor.apana.org.au> <48D9EC4B.4050804@iki.fi> <20080924075441.GA7391@gondor.apana.org.au> <48DA3E2D.4070909@iki.fi> <20080924140819.GA10022@gondor.apana.org.au> <48DB29A9.2090204@iki.fi> <20080925075715.GA18101@gondor.apana.org.au> <48DB4EE7.2030109@iki.fi> <20080925085634.GA18853@gondor.apana.org.au> <48DB536A.7020209@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59679 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752929AbYIYKXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 06:23:31 -0400
Content-Disposition: inline
In-Reply-To: <48DB536A.7020209@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2008 at 12:01:30PM +0300, Timo Ter=E4s wrote:
>
> Not sure if I can finish it today, but I think I should have the
> time by tomorrow. Unless you have time to do it before that, I'll
> post a patch later this week. Will update the similar xfrm_policy
> patch for that too, before sending it.

Thanks! I've got some other work to do so feel free to post this
tomorrow.
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
