From: David Miller <davem@davemloft.net>
Subject: Re: Linux 2.6.34-rc3 + CAN build problem
Date: Tue, 13 Apr 2010 03:09:30 -0700 (PDT)
Message-ID: <20100413.030930.106805212.davem@davemloft.net>
References: <4BC03340.5020500@freemail.hu>
	<1270892851.2093.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nm127@freemail.hu, socketcan@hartkopp.net,
	oliver.hartkopp@volkswagen.de, urs.thuermann@volkswagen.de,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1270892851.2093.32.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 10 Apr 2010 11:47:31 +0200

> [PATCH] can: avoids a false warning
>=20
> At this point optlen =3D=3D sizeof(sfilter) but some compilers are du=
mb.
>=20
> Reported-by: N=E9meth M=E1rton <nm127@freemail.h
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
