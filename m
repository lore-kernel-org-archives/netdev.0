From: Markus Pargmann <mpa@pengutronix.de>
Subject: Re: Broadcom BCM54610 Linux support
Date: Wed, 8 Jul 2015 07:22:21 +0200
Message-ID: <20150708052221.GG25160@pengutronix.de>
References: <20150707105824.GK4552@pengutronix.de>
 <559C0DC0.9070003@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="V32M1hWVjliPHW+c"
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48606 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbbGHFWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 01:22:24 -0400
Content-Disposition: inline
In-Reply-To: <559C0DC0.9070003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--V32M1hWVjliPHW+c
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Jul 07, 2015 at 10:34:56AM -0700, Florian Fainelli wrote:
> (adding Michael)
>=20
> On 07/07/15 03:58, Markus Pargmann wrote:
> > Hi,
> >=20
> > I found the phy driver which supports broadcom BCM5461. But I am not
> > sure if this driver does support BCM54610 in fiber mode as well? Or if
> > there are any open datasheets which could be used to write a mainline
> > driver for it. I would appretiate any information about this.
>=20
> There are not publicly available datasheets as far as I can tell, the
> current driver does not support anything but copper modes.
>=20
> If you have reference code from somewhere else (e.g: bootloader or a
> Broadcom SDK), I would be inclined to port it over the Linux PHY driver.

Thanks. Unfortunately I don't have any reference code that I could use
to support BCM54610 in fiber mode. So it's probably better to use a
different PHY with more public information.

Thanks,

Markus

--=20
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |

--V32M1hWVjliPHW+c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVnLONAAoJEEpcgKtcEGQQf+kP/0MkaEdfbeqcl3grag9BKAR5
X0QuBUzYtUoEm0LVxF/DNGzV94bzrZyw6H0f2KO/IUrUXxcO/PjrSk8/fLe6CUmT
ciLKyLyFfzcNlfDwff270DrlrfmfxrAGnNS0bY4Vx/ZvX6BuT/fwTfxxhc9Jl1V0
aL3XnwBybw0a5cfpZxeQT/CzQgXE7QlYeTuJnSzvacBPDzdKRTncZkboBojJtEqF
EyMZf3s6fgYgmqKB7K+5BBhZz97u5vs7u+KgVFLSQvCtfrt7sBejkgGrnA4jp3yp
nbfxQ+Aq1/HkLqLijzCRmxn9Mpc4oPtETr2k23Unh+a50BpbkWGoFSk0PeuXichP
0ae2ankikrQAvLp0xB+fTb7RkxeKycab0RrY82rCkSkHPb/kS011V2Xoz0DfuolI
aAGuzr9dmeY8d3trJ6+wwcngCAZh2MmiqXTNs287xinShAmRpiZxp9D8cZO+SWc6
U16KKfvsfIU6bECiGgd/jplP9SyqTiryomHnft7PAFMDKErXjCsUxJ5cCqhSSV0Q
9Wt7Pe+KJFcRwkzCjHgV4hokgDidgmhuFN0wwzsD6IDgrxn0My0w7kbvJv3W6PqP
0kmCx76AwSFPuKh0Yc+elQXAaDh9Y8aMhbZOjK35ICu+/Hs+QI7VuE2GCGDE4tsL
jtd7tqBnyByuLVSqM2da
=kl5X
-----END PGP SIGNATURE-----

--V32M1hWVjliPHW+c--
