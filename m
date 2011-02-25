From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ref0] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 25 Feb 2011 10:34:56 -0800 (PST)
Message-ID: <20110225.103456.226779149.davem@davemloft.net>
References: <AANLkTikXUyQy+fjFSwagB3Uud2JPodsR2yFtt+jiZPSk@mail.gmail.com>
	<AANLkTikmqQfT1s2Z6J+KYmqi0CuCc4+2k67eeb4ydtCM@mail.gmail.com>
	<1298631127.2659.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ratbert.chuang@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bhutchings@solarflare.com,
	joe@perches.com, dilinger@queued.net, mirqus@gmail.com,
	ratbert@faraday-tech.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298631127.2659.22.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 25 Feb 2011 11:52:07 +0100

> Le vendredi 25 f=E9vrier 2011 =E0 17:45 +0800, Po-Yu Chuang a =E9crit=
 :
>=20
>> It's a little faster than v5 now. Thanks.
>> I will submit the current version later.
>>=20
>> One more question just curious, why 128 bytes?
>=20
> Probably its best for NIU hardware specs
>=20
> You could try 64, as it should be enough for most IP/TCP/UDP processi=
ng.

IPV6.
