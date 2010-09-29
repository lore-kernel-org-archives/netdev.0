From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Wed, 29 Sep 2010 10:22:38 +0200
Message-ID: <1285748558.2615.16.camel@edumazet-laptop>
References: <20100929.002544.183044247.davem@davemloft.net>
	 <1285746352.2615.11.camel@edumazet-laptop>
	 <20100929075758.GA5188@gondor.apana.org.au>
	 <20100929.010056.115931816.davem@davemloft.net>
	 <20100929080303.GA5318@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40605 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754596Ab0I2IWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 04:22:43 -0400
Received: by fxm14 with SMTP id 14so292003fxm.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 01:22:42 -0700 (PDT)
In-Reply-To: <20100929080303.GA5318@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 29 septembre 2010 =C3=A0 17:03 +0900, Herbert Xu a =C3=A9cr=
it :
> On Wed, Sep 29, 2010 at 01:00:56AM -0700, David Miller wrote:
> .
> > > 	options ipv6 disable=3D1
> > >=20
> > > If so then that's what should be used in this case.
> >=20
> > That's what one should use "always" :-)
> >=20
> > Bonding has the same issue, and it's why we added the
> > disable module option, so that the /bin/true stupidity
> > could stop.
>=20
> Right, that settles it :)

OK guys, you convinced me ;)


