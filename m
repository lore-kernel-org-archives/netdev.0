From: Ben Hutchings <ben@decadent.org.uk>
Subject: RE: [linux-firmware v2 1/2] rtl_nic: update firmware forRTL8111E-VL
Date: Thu, 11 Aug 2011 13:46:18 +0100
Message-ID: <1313066778.2591.1280.camel@deadeye>
References: <1312978979-1808-1-git-send-email-hayeswang@realtek.com>
	 <1312980860.2591.1267.camel@deadeye>
	 <9DEF5678E5044F80AEBAD3FE738EA980@realtek.com.tw>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-1FGpWfomrSoMOBDpkUST"
Cc: dwmw2@infradead.org, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59675 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755665Ab1HKMqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 08:46:30 -0400
In-Reply-To: <9DEF5678E5044F80AEBAD3FE738EA980@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1FGpWfomrSoMOBDpkUST
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-08-11 at 11:41 +0800, hayeswang wrote:
>=20
> > -----Original Message-----
> > From: Ben Hutchings [mailto:ben@decadent.org.uk]=20
> > > +File: rtl_nic/rtl8168e-3.fw (Version: rtl8168e-3_0.0.1)
> > [...]
> >=20
> > Please don't write the version in yet another way.  It should be:
> >=20
>=20
> I just think if someone replaces the firmware with another one, I could c=
heck
> the firmware through the information without checking the ram data.
> For example, someone renames the rtl8168f-1.fw to rtl8168e-3.fw and repla=
ces the
> original rtl8168e-3.fw. Through ethtool to show the version of the firmwa=
re, I
> could know the firmware is invalid. If the version only contain the value=
 0.0.1,
> I must compare the binary file to find out the result.
[...]

You're talking about the version string inside the firmware file.  I see
the value of including the name there.  However, in the WHENCE file it
is redundant.

But I really don't care that much.

Ben.


--=-1FGpWfomrSoMOBDpkUST
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATkPPGee/yOyVhhEJAQqdGRAAvy+dPdWNJkORO0j/4wouIyfPgoLgfm1o
snlDZmGjZo+Nw9ukJl0CP+BREGVlJDcv1DdAQe/GBDwPBV3TM1g8S7VfKIurcHC0
s3l+J6lzvkUHRuFLaSTjepv/8hNhDicamQM1bsDa+FJXsiaxX+hcU93FlTH0zCVV
d2Dir6afFUqjujNoU91NHrCAC7UCHepm5ESHTkJtraJOmaaZsrBdaDBGMX1cTpw1
uqKySo5F3QNBJq5z513t5rjEqnAxTQNAK+PsxHUcs6jQVX+I71ORYaHdYx6vy4UL
tdTXciP2mJU5MWTTL3n4NasF8r5KKn5eU0Q7NqphR2Bd5mmv4WvlFhhnWt+2cxGq
TBizyO8du6Lm+JcG0IJEJh4t9/i37adJSuHuF7azLI2LH5SJ071xtDR7WWvbYMHZ
6XK5nfpZQXujaecwE8/1rs8h+6M4bcXfpl9+tCXfLpy6p9N7mFz9e1p/F9KD1aUJ
WKEtD5nLTCDj0WRxrDVQfvrVeYwSip6z9ZCnOTdvOJ1kbImO235Tr+8Xag6fY4MC
zO7iZyLE6onS7+E2aHaljEzVBsQBDiF3gI0xoGWohGCR+PzMUddAKdIBfJD+c41B
res/B2RLVkXXOFzWFQdVJKaDTrlaUaH4MPskJEi7UJpxfAdUmUK4ApI1Da64PPur
ABnpj3IT3cU=
=XcH1
-----END PGP SIGNATURE-----

--=-1FGpWfomrSoMOBDpkUST--
