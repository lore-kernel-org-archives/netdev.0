From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] bnx2x: update fw to 7.8.17
Date: Mon, 11 Mar 2013 14:57:48 +0000
Message-ID: <1363013868.3937.34.camel@deadeye.wl.decadent.org.uk>
References: <1361993047-10127-1-git-send-email-dmitry@broadcom.com>
	 <1362845900.3768.496.camel@deadeye.wl.decadent.org.uk>
	 <504C9EFCA2D0054393414C9CB605C37F1C03C50E@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qUlfa6u9qYYAlnZfUY0T"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	David Woodhouse <dwmw2@infradead.org>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37827 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751319Ab3CKO6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 10:58:06 -0400
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F1C03C50E@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qUlfa6u9qYYAlnZfUY0T
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-03-11 at 14:43 +0000, Dmitry Kravkov wrote:
> Hi Ben,
>=20
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org=
] On Behalf Of Ben Hutchings
> > Sent: Saturday, March 09, 2013 6:18 PM
> > To: Dmitry Kravkov
> > Cc: netdev@vger.kernel.org; Ariel Elior; Eilon Greenstein; David Woodho=
use
> > Subject: Re: [PATCH] bnx2x: update fw to 7.8.17
> >=20
> > On Wed, 2013-02-27 at 21:24 +0200, Dmitry Kravkov wrote:
> > > This new firmware includes the following changes:
> > >
> > > 1. Several corner case bugs in iSCSI code.
> > > 2. Fixes for FCoE including support for 3PAR targets.
> > > 3. Fixes for SR-IOV behaviour including:
> > > 	a. Remove FW assert erroneously triggered during FLR.
> > > 	b. Several fixes in FLR flow.
> > > 	c. Prevent VF crash when packet bigger than MTU arrives.
> > > 	d. Improve security against malicious VF.
> > > 4. Added CSUM and TSO support for encapsulation protocols.
> > > 5. Added RSS capability for GRE traffic based on inner headers.
> > > 6. Added FCoE support for 4-port 57840 devices.
> > >
> > > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> > > Signed-off-by: Ariel Elior <ariele@broadcom.com>
> > > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> > > ---
> > > Please consider adding to linux-firmware tree.
> > [...]
> >=20
> > Applied, thanks.
> >=20
> I'm looking for the FW at
> git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
> but the latest commit there is:
> commit c11f374afdd2a3ff0665c1cb0aab4ad0c6573ec7
>     cx231xx/cx23885: Remove incorrect Conexant CX23885 firmware=20
>=20
> Am I looking at the right location?

Yes, I just hadn't pushed it yet.  Should be there in a few minutes.

Ben.

--=20
Ben Hutchings
The obvious mathematical breakthrough [to break modern encryption] would be
development of an easy way to factor large prime numbers. - Bill Gates

--=-qUlfa6u9qYYAlnZfUY0T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUT3w7Oe/yOyVhhEJAQozog//e1XAel1f6fD9szA3czp/R1YFoiA17sAD
r9RbFnNBZ9bcQ4mjRrSPboHStFglyRdTjro9K8m9TCrfx5goCr9lawefehBPyKLU
SoRO6fuGMd/r0aoqIKAtPs/hAaJLN49Fiea2QdpLA1oJ1bmnE2G+1CAzn5gCfD0o
uFznn2tAs19yKBzv4vg1raU06ES8bJEvYCfpDqgr5Z126Kp5OQvgkDMvxbn6Pxd1
bIJ6a5XJ8PFzVUadO1cBMDI7McGqvyH8nVrF8YUbA8QF3ZLksvoV0ScMqxbfm/wg
9pzwMjs5JtbQ+rvI6tO1JD+to+dFpSIRz1UV3UDqHUMAG2UKz3ey0/HqRd94aUGS
frltYOvfIbV1jkEhRRx51c6Wn45g+rXMR1W7/qJCj8cCijlgZP3I4nes6Ua3fnDv
szAYEHYp6HIWgIEneZA/nzxA2nJNNXAbwCgqW/tfhelcrZlbFu05+5zVNq1MHCQf
Ba/XtOmIqrRqCWLbcumQYD7B0wafKDJM2iJx+Gf0dGke9eretHU9cuE8VflWWxal
Zm1Rf7i46TWU+QnBLEXQ2RohZz7vuxhAc2ZaTLc1otn8d4rEazP4dE1epnXrr/BA
LYIejxESOel85x6OcSrXYxkbCW9FfGfO8NdOMYgKyHuNUOJY0PmlQSRY7i5yWk43
VNsp0iAM2vQ=
=7ow9
-----END PGP SIGNATURE-----

--=-qUlfa6u9qYYAlnZfUY0T--
