From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH/RFC v1 00/12] Support for Broadcom 63xx SOCs
Date: Wed, 22 Oct 2008 15:58:23 +0200
Message-ID: <200810221558.27338.florian@openwrt.org>
References: <1224382022-24173-1-git-send-email-mbizon@freebox.fr>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2962902.4p7LAVTyHT";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org,
	afleming@freescale.com, jgarzik@pobox.com,
	linux-usb@vger.kernel.org, dbrownell@users.sourceforge.net,
	linux-pcmcia@lists.infradead.org, linux-serial@vger.kernel.org,
	linux-mips@linux-mips.org
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <1224382022-24173-1-git-send-email-mbizon@freebox.fr>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2962902.4p7LAVTyHT
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello,

Le Sunday 19 October 2008 04:07:02 Maxime Bizon, vous avez =E9crit=A0:
> CPUs supported are  6348 and 6358. Support is  provided for integrated
> UART,  USB OHCI  and  EHCI, PCI  controller,  ethernet MAC  & PHY  and
> PCMCIA/Cardbus controller.

I got some pending patches on top of yours to add support for earlier : 633=
8=20
and 6345, as well as newer revisions of the SoC : 6368 and 6816.=20
Additionnaly, the cable version (BCM3348/BCM3349) should be fairly well=20
supported now, for which I need to have a serious try.

I prefer you get some feedback on your patches first before submitting my=20
changes.
=2D-=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
=2D------------------------------

--nextPart2962902.4p7LAVTyHT
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkj/MYEACgkQlyvkmBGtjyamHwCggOIQTTLwf5Y2y0CH7tme3706
CssAnRZXTrJJgdZrFmSwCuVctVowUk15
=PSMQ
-----END PGP SIGNATURE-----

--nextPart2962902.4p7LAVTyHT--
