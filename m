From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] econet: Move to staging; remove from defconfig
Date: Sun, 28 Nov 2010 02:02:23 +0000
Message-ID: <1290909743.3292.248.camel@localhost>
References: <1290897868.3292.59.camel@localhost>
	 <20101128002135.GA4562@suse.de>
	 <20101127.172644.226781076.davem@davemloft.net>
	 <20101128013923.GA9285@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-rm3kQDFrm96O3raYYbym"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org, linux-arm-kernel@lists.infradead.org,
	debian-kernel@lists.debian.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59766 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751149Ab0K1CC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 21:02:27 -0500
In-Reply-To: <20101128013923.GA9285@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rm3kQDFrm96O3raYYbym
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-11-27 at 17:39 -0800, Greg KH wrote:
> On Sat, Nov 27, 2010 at 05:26:44PM -0800, David Miller wrote:
> > From: Greg KH <gregkh@suse.de>
> > Date: Sat, 27 Nov 2010 16:21:35 -0800
> >=20
> > > And I need an ack from the networking maintainer to be able to accept
> > > this also.
> >=20
> > I'm not applying this, nor do I want anyone else to.
> >=20
> > If people think this protocol is not maintained adequately
> > right now, wait until you push it into staging.
> >=20
> > Furthermore, once Phil Blundell was made aware of security
> > holes in econet he fixed them within a few days.  Which is
> > much better than I can say for some of the other protocols
> > and filesystems in the tree.
> >=20
> > Moving this into staging, is therefore not appropriate.
>=20
> Agreed.
>=20
> Ben, why are you trying to remove these protocols that people use and
> maintain?  This is the third one that has been shot down recently...

Moving to staging is a step toward removal, but not removal itself.  I
already stated the reasons I picked those three protocols; I'm not going
to push the issue if David disagrees.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-rm3kQDFrm96O3raYYbym
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATPG4Kue/yOyVhhEJAQKXSw/+MTz0QZybjfHhJb3khjR3BMT4T6Qx1xM7
Kp4QKIlbMkqlpP75LOLoXJikseLdj9GVef5THbDzYWL5rVN5QOz3X5yUsYknDa2c
DUcazqVxT7EblTUH1tlQtH4Evr4Zu0hHkVyuwFsfKU8MN/JonSDMwpsbIEJER1GV
oSrDW6TcGZSQsox/Tr9leRS13QjLCgzcqBR6rLed2+oT0k4GUCFYg1cFhYavhof+
RG0yMKJMjVHdcJjOa+TEolNtNhL1CJW2LysRCbHauZyLe48/X2xNNQsnfBiEUZ/l
We9nw4Bl8ha7Jpaa4ovnx1iN/MWv/mI5fwNOs1rEwxaB7Dw24CNIa87xhsbTy7AD
CnxpbrX5BowwTeQY/7SbemHP/P6aCwWhL3bcFlNV0JyLUudS02iIteUG/paywyC3
QTuAAlSlCOtbF6DEc8yX0Lu8htuL6yT4OmE7qC+fSrdV/2rqOD5cyR313eMbPlCj
3MvV+atSGn0K+So/MqlQfk9VMNwLcQSBNDe32fIplDL5WF+5k1Cy5UcBzbZY2v5U
Thch5Rm70kkSYm14yLhJDd4RMwkUypQ1uXCEXjj8BnnGUngLngY7ytLbz7eetneu
XWnzP7pvynzouvOKJxZB1QwNw3HB0wkAvWR1Ri/wZpalrNLqfsllyqo9unCic0cX
OxX2vwUuveg=
=cFXq
-----END PGP SIGNATURE-----

--=-rm3kQDFrm96O3raYYbym--
