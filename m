From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tg3: fix VLAN tagging regression
Date: Wed, 21 Sep 2011 00:11:14 +0200
Message-ID: <1316556674.5832.3.camel@edumazet-laptop>
References: <4E78FC38.7040903@kasperkp.dk>
	 <20110920210929.GA9652@mcarlson.broadcom.com>
	 <CAEP_g=9V=5zHqwz710TSuRSqTdo1kqkKF2VEEV6K3Tv1zupegg@mail.gmail.com>
	 <4E790C5E.5000000@kasperkp.dk>  <1316556533.5832.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kasper Pedersen <kernel@kasperkp.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1316556533.5832.1.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 21 septembre 2011 =C3=A0 00:08 +0200, Eric Dumazet a =C3=A9=
crit :

> Thanks for finding this bug, this hit me last day on a BCM5755M but I
> had no time to investigate.
>=20

I meant a BCM5715S, but its probably a generic bug anyway ;)
