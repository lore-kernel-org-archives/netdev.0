From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH-RFC] drivers: net: ethernet: intel: e1000e: fix ethtool
 autoneg off for fiber
Date: Wed, 30 Mar 2016 12:44:09 -0700
Message-ID: <1459367049.2903.7.camel@intel.com>
References: <1458943126-32258-1-git-send-email-danielwa@cisco.com>
	 <56FC2A62.6040206@cisco.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-y+v6ngcM/3OD4L/rVaFn"
Cc: Steve Shih <sshih@cisco.com>, danielwa@fifo99.com,
	xe-kernel@external.cisco.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
To: Daniel Walker <danielwa@cisco.com>, dima.ruinskiy@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62980 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753055AbcC3ToY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 15:44:24 -0400
In-Reply-To: <56FC2A62.6040206@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-y+v6ngcM/3OD4L/rVaFn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-03-30 at 12:34 -0700, Daniel Walker wrote:
>=20
> So Intel maintainers (Jeff, Jesse, Shannon, Carolyn, Don, Bruce, and
> John)
>=20
> I'm assuming no comments means this patch is acceptable , and I will=C2=
=A0
> resubmit it without the RFC. Is that acceptable ?

I personally do not see an issue with the patch, go ahead and submit it
as a non-RFC and I will make sure that the e1000e maintainer (Dima
Ruinskly) reviews it.
--=-y+v6ngcM/3OD4L/rVaFn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW/CyJAAoJEOVv75VaS+3O8CgP+QGgrfo/ioViJ/Avga8/1lZ9
fxoVtM3pxu2yh2WooygBpgvfHRw2SLsJYa9vEwiZUOWChJGlS9jlYVaz/Ba238J4
wStEqwGh+GPvF3yueLqJUkc4L0iBgucGQA5sRKlq+gZTad9Zub9nXtqwduhYqjS+
ZuYMYRwY7UWmjtq0+0ZTyo/UxLPklN1k0BVrf29lAxbGHwJbxVJyPrQ4FNeVcRMm
QIUWGR5u9EH5rR6cH5CCU39NQIWXRNBfoJoCco/tlEmzHfhyPmy17AseMFMKIX1I
mUBzcJWQIQrAh0+h5TPZIwoPwSDSqfss1zmC39IPfdltrCsTA2UTX0rZiOgqp0ZO
Z1NoPqGlJSRxe4z9aBCA5Qh7mYD6KieAKbbioW3XfHw+fISPJ3ddDyIqG9UVdCTZ
yWc4SOuxekCMVIAIK/PnKHo6S1KZUjkjaIWb2k+Voi7Jllr0IKU7HAVxFayeIVyX
wtUpVfGV2QUgAkwkGF3lWzoBc6Qhf++fXhjCk7LURWSuvHLPbLTePwF0SlovSiyf
YinpR3eOjoELZEVDrYGV+kJ06uq7alnpfMxLveWETyqHZ+4XuCwh+v13I7hQivdG
cg+jd8z8FpN2prt0Y95CkRhaqQLDXWj42QFSGFgOlLHuKkSfxxGp4+j+c5cae+Pd
POYnJfgSiebjlt6xs9sC
=fQ1M
-----END PGP SIGNATURE-----

--=-y+v6ngcM/3OD4L/rVaFn--
