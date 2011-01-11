From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Tue, 11 Jan 2011 18:01:13 +0100
Message-ID: <1294765273.2927.65.camel@edumazet-laptop>
References: <1294764515-15356-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com,
	jj@chaosbits.net, daniel.baluta@gmail.com, jochen@jochen.org,
	hagen@jauu.net, torvalds@linux-foundation.org, pavel@ucw.cz
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294764515-15356-1-git-send-email-stefani@seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 11 janvier 2011 =C3=A0 17:48 +0100, stefani@seibold.net a =C3=A9=
crit :
> From: Stefani Seibold <stefani@seibold.net>
>=20
=2E..
> The implementation is clean and has absolut no side effects to the ne=
twork
> subsystems so i ask for merge it into linux, mm-tree or linux-next.
>=20
> The patch is against the current linux git tree
>=20
> - Stefani
>=20
> Signed-off-by: Stefani Seibold <stefani@seibold.net>
> ---
> =20

Reading again UDPCP specs, I find it is IPv4/IPv6 agnostic

You copied IPv4 UDP code, so this only handles IPv4...
