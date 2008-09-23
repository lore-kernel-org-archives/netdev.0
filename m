From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 19:24:16 +0800
Message-ID: <20080923112416.GA28946@gondor.apana.org.au>
References: <20080922114256.GA27055@gondor.apana.org.au> <48D7971A.5050107@iki.fi> <20080922235012.GA23658@gondor.apana.org.au> <48D8763E.4030607@iki.fi> <20080923045951.GA26048@gondor.apana.org.au> <48D87BDA.8040804@iki.fi> <20080923052239.GA26233@gondor.apana.org.au> <48D88BCC.5030806@iki.fi> <20080923064707.GA26836@gondor.apana.org.au> <48D8B967.8000107@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46567 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750899AbYIWLY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 07:24:26 -0400
Content-Disposition: inline
In-Reply-To: <48D8B967.8000107@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 12:39:51PM +0300, Timo Ter=E4s wrote:
>
> This would make it possibly to reclaim the deleted entries right
> away.
>=20
> Does this sound better?

Yep this sounds pretty good to me.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
