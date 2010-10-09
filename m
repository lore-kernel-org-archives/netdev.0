From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Tarpit target for the last stable (2.6.35.7): right
 version
Date: Sat, 09 Oct 2010 08:10:50 +0200
Message-ID: <1286604650.2692.1.camel@edumazet-laptop>
References: <4CAF6A83.6090004@gmail.com>
	 <1286565042.2282.6.camel@achroite.uk.solarflarecom.com>
	 <alpine.LNX.2.01.1010090609350.1542@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Nicola <nicola.padovano@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1010090609350.1542@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 09 octobre 2010 =C3=A0 06:21 +0200, Jan Engelhardt a =C3=A9cr=
it :

> I must say I am surprised.
>=20
> There already exists a maintained xt_TARPIT in Xtables-addons, and
> it seems like your patch is a duplicate effort of it.
>=20
> If you have any updates to xt_TARPIT, I would recommend the strategy
> that Luciano Coelho used when he wanted to have xt_condition in
> the main kernel:
>=20
> 1. take the maintained version from Xt-a
> 2. submit any updates to the Xt-a file, if feasible
> 3. once processed, submit that then for Linux kernel inclusion
> 4. apply further updates to the LK file, if needed
>=20
> That way it is way easier to know what specifically new features you=20
> have added to xt_TARPIT, if any.
>=20

Agreed, so much messages on netdev and netfilter-devel, only to rewrite
a TARPIT module :-(



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
