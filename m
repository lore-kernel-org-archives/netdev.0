From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] i40e: crash on NMI by continuous module reload
Date: Fri, 27 Feb 2015 16:45:58 -0800
Message-ID: <1425084358.9477.76.camel@jtkirshe-mobl>
References: <54F07630.1010802@kpanic.de> <54F078DF.5020100@gmail.com>
	 <54F07C29.8010805@kpanic.de> <54F082C8.8040407@gmail.com>
	 <FC41C24E35F18A40888AACA1A36F3E418ADF339C@fmsmsx115.amr.corp.intel.com>
	 <3DA4D8F9-C0E0-41B9-8F9C-BD17BC7A09B3@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ON8iRdCb7ZMaXvFyZEC5"
Cc: "Nelson, Shannon" <shannon.nelson@intel.com>,
	Stefan Assmann <sassmann@kpanic.de>,
	netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42744 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179AbbB1Ap7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2015 19:45:59 -0500
In-Reply-To: <3DA4D8F9-C0E0-41B9-8F9C-BD17BC7A09B3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ON8iRdCb7ZMaXvFyZEC5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-02-27 at 16:25 -0500, Nicholas Krause wrote:
> Thanks Shannon,=20
> For the advice on there being a newer driver and firmware to test that
> on before reporting the bug against this driver. I am curious as to
> why this newer code is not up streamed to Linux next yet through.

Because I still have ~40 patches in my queue for i40e that need to go
upstream to get the upstream driver in sync with our out-of-tree driver.

Also Nick, please do not take advantage of me being nice to you and
letting you remain on e1000-devel mailing list, even though you have
been banned on @vger.kernel.org mailing lists.  It is clear from your
attempts to help Stefan, you do not know the driver and your "blind
stabs in the dark" to assist, only hinder our abilities to assist
others.

--=-ON8iRdCb7ZMaXvFyZEC5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU8Q/GAAoJEOVv75VaS+3OdowP/1TYVEDcTZjg+3+Rw/V4VpGj
hGZqrdiCJNe/lECToXDMHGnDt/NKrtuAC6Q+haicRHtBEk1BC2/Q1Y43I1BNXIiv
Rgtl/CbSyhGg0LaV2kpdncEszk3XdMNRch/PW3q57HB44EWzqdlE/pGEQNRmY2Nd
vui+JBMkyXtnZ07mH6+DRi191P80k/CBU8kg2HpMlsUF/hVu9FvMVMXuENhDWwYb
STo9ASnMUAZ8WVWSh1laXo532E31zeVCHvTkY+Ap47093s4/pNjGHvcQASpu2HMs
Z/knM01IjD57itvJlF7URh9RIM40FrThHUbO3k6O9nk4lkVIvtWppB5M9efaWtRo
CSu+e+8kcvxWs/nZUfVAmXt5SLFY4jQg/HJIaKYG7PDIaAb8Q/Q2MWich2HL/BGY
+/Kf7VN0f/O6eaeL7rWZNJV/W2o5ZF+MmBEa7wmUebqZmL3jv2y/fhLgLVWevgSA
a+E+t696qxNWvpEZy6YhdPF4zaoAzCsPY8+rb0EotrzLfn0N1nnrtGUJkF9BS6gw
qXUlp5n46yU5g+FaS1t/ApenlO3eAYl5c/yxpqDJ7pOFOifA2XN+mkL9M6lYjsP4
97+fhfUmQzyHAq3UCQy612eTYjLCephz/gQ8/W81rUmZQGZc3GV2zJleCb5Zvb2E
smCPBbSgxzVFx5SW4SAL
=4lbe
-----END PGP SIGNATURE-----

--=-ON8iRdCb7ZMaXvFyZEC5--
