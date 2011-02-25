From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ref0] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 25 Feb 2011 11:52:07 +0100
Message-ID: <1298631127.2659.22.camel@edumazet-laptop>
References: <1298535761.2814.1.camel@edumazet-laptop>
	 <1298539762-2242-1-git-send-email-ratbert.chuang@gmail.com>
	 <1298569179.2814.11.camel@edumazet-laptop>
	 <1298569685.2814.16.camel@edumazet-laptop>
	 <AANLkTikXUyQy+fjFSwagB3Uud2JPodsR2yFtt+jiZPSk@mail.gmail.com>
	 <AANLkTikmqQfT1s2Z6J+KYmqi0CuCc4+2k67eeb4ydtCM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, davem@davemloft.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikmqQfT1s2Z6J+KYmqi0CuCc4+2k67eeb4ydtCM@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 17:45 +0800, Po-Yu Chuang a =C3=
=A9crit :

> It's a little faster than v5 now. Thanks.
> I will submit the current version later.
>=20
> One more question just curious, why 128 bytes?

Probably its best for NIU hardware specs

You could try 64, as it should be enough for most IP/TCP/UDP processing=
=2E
