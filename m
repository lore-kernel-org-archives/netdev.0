From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 02/13] phy: add the mvebu cp110 comphy driver
Date: Thu, 24 Aug 2017 16:01:40 +0200
Message-ID: <20170824140140.GC28443@kwain>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-3-antoine.tenart@free-electrons.com>
 <20170824133922.GC8022@lunn.ch>
 <20170824134444.GA28443@kwain>
 <20170824135127.GE8022@lunn.ch>
 <e83030e8499843e8af9004c2562380dc@IL-EXCH01.marvell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="1SQmhf2mF2YjsYvc"
Cc: Andrew Lunn <andrew@lunn.ch>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kishon@ti.com" <kishon@ti.com>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        "linux@armlinux.org.uk" <linux@armlinux.org.uk>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mw@semihalf.com" <mw@semihalf.com>,
        "miquel.raynal@free-electrons.com" <miquel.raynal@free-electrons.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stefan Chulski <stefanc@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <e83030e8499843e8af9004c2562380dc@IL-EXCH01.marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--1SQmhf2mF2YjsYvc
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Stefan,

On Thu, Aug 24, 2017 at 01:57:04PM +0000, Stefan Chulski wrote:
>=20
> > > How would you name it if not "comphy-cp110"?
> >=20
> > Good question...
> >=20
> > '7000-cpmphy-cp110'
> > '8000-cpmphy-cp110'
> >=20
> > ??
> >=20
> > 	Andrew
>=20
> A8K Marvell SoC has two South Bridge communication controllers
> and A7K only one communication controllers, but its identical
> communication controllers 110. Next generation will has another number 1x=
x.

OK, so I guess we can keep 'comphy-cp110' then.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--1SQmhf2mF2YjsYvc
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlme3EQACgkQXE2LyK3b
vNgGAg//d85RnjChGlsM5F2+wZZFZebbdiTh1X+cIWWCgr2OqFiXG7WbpNg9Bq1r
eQFMqRTGJqU4ANGmsl9Des8NVMNWyHTYznwcLI1bZPpd+llpm+JMFfLYKWqpcYIu
Req2tOfKI4JsSINeKD7/XONJfmK4B+PUPMf8hFQom0ndzOa5ljBFh764xMHEQiFu
N5SoOv7q40PHVOO+SIFmKyBPaiksq5lPfQX5L3Mh1STTnCpxbo0gHEMDV9X7soN/
Q59WN+UIfderUy9A3dIX9NJ6vR1MNMfHJ/K5eu/usrLiG27CH4qJkAkALktSV9kI
1bZKFdMbt/HTep2ajkimzMRAzNnrSCcYC1ZYNNo6X6D+jksu827rJ0mhO2yIp3Iu
MrbgxEfKhVa9356W0ufG8kI0J4p/kTjAoAyVvELABOPN4wRKSJvdzaO929G5aql7
W9pV/+szpfnF0mscYfBlgQ6NUBseOLjBXiZ5TLQ1clRh3FEJiviMvmwDvPQFFYJ0
TulY0SMKVbpYgaTAaWPmk92LdjOtQe+29AhcQcPs0qbV9BgbN/N+YWKJLL/q8k/e
fUEv6LjJ1btBL+NJQjzi6BMRokLF/iz41xmh9h48u/QwpIGgeiC1qFpIXp25AOoo
QUwvv2KTRqz0dYeV1CQwZZfcFmh0XUR3xCpe7QtXPZG3E/p8+3Y=
=ckYO
-----END PGP SIGNATURE-----

--1SQmhf2mF2YjsYvc--
