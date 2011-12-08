From: =?utf-8?Q?Lothar_Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: Re: [PATCH v2 0/8][NET] fec.c: several cleanups and bugfixes
Date: Thu, 8 Dec 2011 08:01:01 +0100
Message-ID: <20192.24749.652755.425707@ipc1.ka-ro>
References: <cover.1323256319.git.LW@KARO-electronics.de>
	<20111207.133800.1403774147364781100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shawn.guo@linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111207.133800.1403774147364781100.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

David Miller writes:
> From: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> Date: Wed,  7 Dec 2011 14:37:12 +0100
>=20
> > The following set of patches provides some cleanup and bugfixes for
> > drivers/net/ethernet/freescale/fec.c and makes the driver buildable=
 as
> > a module.
>=20
> 1) I said to use a subject prefix of "fec: " not "fec.c: "
>=20
OK.

> 2) You did not integrate Shawn's "Acked-by: " tags, I'm not going to
>    go sifting through the previous patch postings to collect them up,
>    that's your job.
>
I still got no Ack from Shawn for patches 3 and 5 and only Tested-by
for patches 6 thru 8. Should I wait for Shawn's Ack for those patches
too, or should I resent now?


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
