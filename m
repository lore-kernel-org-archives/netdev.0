From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: Patch: add loglevel to printk's in net/ipv4/route.c
Date: Wed, 29 Dec 2004 00:23:43 -0200
Message-ID: <41D2152F.8080501@conectiva.com.br>
References: <Pine.LNX.4.61.0412290256000.3528@dragon.hygekrogen.localhost> <41D2104D.3010406@conectiva.com.br> <Pine.LNX.4.61.0412290312540.3528@dragon.hygekrogen.localhost> <41D2120E.8030008@conectiva.com.br> <20041229021256.GD29323@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Juhl <juhl-lkml@dif.dk>,
	Networking Team <netdev@oss.sgi.com>,
	linux-net <linux-net@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>
In-Reply-To: <20041229021256.GD29323@wohnheim.fh-wedel.de>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



J=F6rn Engel wrote:
> On Wed, 29 December 2004 00:10:22 -0200, Arnaldo Carvalho de Melo wro=
te:
>=20
>>>It doesn't make much difference, it's mostly for completeness/correc=
tness.
>>
>>No, it does a helluva difference, give it a try :-)
>=20
>=20
> hint: look for "\n"

hint2: Or the _lack_ of "\n" 8)

- Arnaldo
