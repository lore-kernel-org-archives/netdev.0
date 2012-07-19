From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH firmware] rtl_nic: update firmware for RTL8168G
Date: Thu, 19 Jul 2012 01:59:56 +0100
Message-ID: <1342659596.11373.58.camel@deadeye.wl.decadent.org.uk>
References: <1341878937.25597.309.camel@deadeye.wl.decadent.org.uk>
	 <1342008603-1279-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-TU07qcM3HsgQ8Rb64PB0"
Cc: dwmw2@infradead.org, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44103 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751558Ab2GSBAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 21:00:04 -0400
In-Reply-To: <1342008603-1279-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TU07qcM3HsgQ8Rb64PB0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-07-11 at 20:10 +0800, Hayes Wang wrote:
> File: rtl_nic/rtl8168g-1.fw
> Version: 0.0.2
>=20
> Change the ocp_base of linux driver to OCP_STD_PHY_BASE after setting
> firmware. The firmware would modify the ocp_base, and that results the
> driver uses the wrong ocp_base to access standard phy after setting
> firmware.
>=20
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
[...]

Applied, thanks.

Ben.

--=20
Ben Hutchings
DNRC Motto:  I can please only one person per day.
Today is not your day.  Tomorrow isn't looking good either.

--=-TU07qcM3HsgQ8Rb64PB0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUAdcDOe/yOyVhhEJAQoEnA//QcOSqIJfivn8ImOt0qfbSav4PXFvmDBE
ujQuSZaFwdDQkz56OLyUei56EvS/N4LSNoqEcUKZTGNun7Lgq8mBOZ6TfVu8Wt6P
Bk8lUSbtEQ/CiAiALFwbzp+KRM/tMRh+VOpVp8t+7umbR3TZ4gn0cpWukRdWv/um
dTC6k78egzwp4DhSwz+70ZOAMuHvHGZlc1dZMNjzlzYoK8C5y4ym2j6wE1Gwyg6N
fGCI6P+mLrfuaN1TqIIcnH/QDrUu8nQ0ao/lxe9ZIJrwxE8mUbyBmp6F3n16sJt5
RydqaY678IJNi+gSHF7AgOf68+yEYS9sK9IpBr69J72Dcg0X4N+Ivf0J2Myn70zA
Qvtk/jciUXlWONt/8isrI10sgFCV6b2P28owCBmn05vYQfnrubmLB5FO6lDMvuIl
RgkQsRkUTwHYU6k9EfM8C+TZoUEEzQweArHx0x0e98QIr1FA1JSBVvPuxaT5DD6/
+qrPC9z/GWvoycJlRWOInO6fVSvM5l4DxgE4DXZYLBMjOYOzdu2+l8do4lDhLkbR
agJjgLmtWDrKmQMfrkV4s842XwCaFDjWzErppfj/JoFmvBG36/MptPC3OUnXM63f
xeDQh4IfJ10/wvs9XwbWWdSsphBk4EVUhO7vpvyCXyEWQ6jWcG4L2atQv8aduvDU
MBkRk+IMyaY=
=JDZl
-----END PGP SIGNATURE-----

--=-TU07qcM3HsgQ8Rb64PB0--
