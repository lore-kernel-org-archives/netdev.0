From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v7 1/2] ethtool.c: add support for
 ETHTOOL_xLINKSETTINGS ioctls
Date: Sun, 26 Jun 2016 10:47:04 +0200
Message-ID: <1466930824.2504.25.camel@decadent.org.uk>
References: <1458922862-98024-1-git-send-email-ddecotig@gmail.com>
	 <1458922862-98024-2-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7o3CX7UnQUeiHDHF1/xL"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55050 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751731AbcFZIrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 04:47:16 -0400
In-Reply-To: <1458922862-98024-2-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7o3CX7UnQUeiHDHF1/xL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-25 at 09:21 -0700, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
>=20
> More info with kernel commit 8d3f2806f8fb ("Merge branch
> 'ethtool-ksettings'").
>=20
> Note: The new features implemented in this patch depend on kernel
> commit 793cf87de9d1 ("Set cmd field in ETHTOOL_GLINKSETTINGS response to
> wrong nwords").
[...]

Applied, with some style changes.  Thanks for your patience.

Ben.

--=20

Ben Hutchings
compatible: Gracefully accepts erroneous data from any source

--=-7o3CX7UnQUeiHDHF1/xL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXb5aIAAoJEOe/yOyVhhEJ/PYP/1aTiBNqgrxb54j86TeYbWkH
yKLML6gEGRJKDfniTySCqYzCZv2m8DEnHsyCN9UAMEKVw0QBFMMRAhAEYEVB+Jt+
3cDuivV7KZRB3Ou8ZQaDDMwKoZ0f72m/HMy1eCgyb0862WzaGtP3lURVN0yh2u2R
7FLF/3QP5OSNmiuRoMU4C6IlJJqAsE5nIYG3RKEymtVvHEip6xQ9pot0ZHf4sOWp
N7vIgHS12bt2jDnGP/swfTlkWkeh99TayYps15L6UIxHemIotupmCW7Lo2YNH3cw
/lgpRfeEEWhD0J4TPaM9kB/HU4IDJAMQa2utrCQP+dRnOA1RJ3O/9cGgRRQ4Eojl
xg5h/OxadlrRmahL/RoB9lOozSHntvNnl5kbpi24G9MGnUnpzMnTmK8CP8Ua1b1/
6MXTZrjn+rcX1gnm1kSjxfiVmimjzqwUFwo2zt8KAyRmu5xP6a+IwjJT+/ScdWqe
8e0duGqxX/Y3DrJr9oEJjqdhr2vY0eysKJ0i1QhAjdOMszH/KNnHZUQdX8JAs+MO
BhEnLSVOiThEprtciZbPmUtAo1Wu01cY19J6Bbo721oMrnu2gMyVMe5qHuUwV/Pd
/nfwBJT74/K3ZQCuTg34w9D/jIe02xYQ3A2HemIJ+aVwGBX+/s8nZ2J4bSja7MOu
lhJu8nwyLFZ6GBrG4TD/
=dDo+
-----END PGP SIGNATURE-----

--=-7o3CX7UnQUeiHDHF1/xL--
