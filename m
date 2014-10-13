From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regarding tx-nocache-copy in the Sheevaplug
Date: Mon, 13 Oct 2014 07:49:19 -0700
Message-ID: <1413211759.9362.103.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141013105246.GD1972@vicerveza.homeunix.net>
	 <20141013142156.GE26864@lunn.ch>
	 <20141013143138.GJ1972@vicerveza.homeunix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Carles =?ISO-8859-1?Q?Pag=E8s?= <page@cubata.homelinux.net>,
	linux-arm-kernel@lists.infradead.org
To: =?ISO-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141013143138.GJ1972@vicerveza.homeunix.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-10-13 at 16:31 +0200, Llu=C3=ADs Batlle i Rossell wrote:
> Enabling tx offload and disabling tx-nocache-copy, making the machine=
 *send* a
> lot of ssh traffic (sftp for example) makes ssh fail HMAC. It's quite=
 easy to
> reproduce here.
>=20
> As for the hardware, it's an old sheevaplug board.


Have you tried disabling TSO only, and are you using the latest kernel =
?

Ezequiel Garcia added lot of changes recently.
