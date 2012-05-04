From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net v2 0/4][pull request] Intel Wired LAN Driver Updates
Date: Fri, 04 May 2012 09:11:28 -0700
Message-ID: <1336147888.2656.106.camel@jtkirshe-mobl>
References: <1336129504-29919-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120504.105815.2251328360345706986.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tQBSb+LO1+IVPHZCsqa0"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9601 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105Ab2EDQL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 12:11:29 -0400
In-Reply-To: <20120504.105815.2251328360345706986.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tQBSb+LO1+IVPHZCsqa0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-05-04 at 10:58 -0400, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri,  4 May 2012 04:05:00 -0700
>=20
> > This series of patches contains fixes for ixgbe, igb and e1000.
> >=20
> > v2: Added e1000 patch to fix sparse warnings and igb/ixgbe to
> >     correct an issue of calling function to reset Tx queue in
> >     init path.
> >=20
> > The following are changes since commit 5a8887d39e1ba5ee2d4ccb94b14d6f2d=
ce5ddfca:
> >   sungem: Fix WakeOnLan
> > and are available in the git repository at:
> >   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master`
>=20
> I pulled, but what is that "`" character doing at the end of that GIT url=
?
> I removed it when I pulled as you don't seem to have a "master`" branch i=
n
> your tree as far as I can tell.

Sorry about that, not sure what happened there.  Guess I missed the ESC
key when editing the cover...

--=-tQBSb+LO1+IVPHZCsqa0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPo/+wAAoJEOVv75VaS+3O1KsP/id57+zmf/IMs0nkPYeZWnGz
Bw6m3zMMq4tsbWX4qTHiBGqYYMdJJhwPEvdB+0HBeuLpnQLu7xw6c3YQx/zO7/QO
V3dgaQfIFJVKBhaFF21gkNKeUR4F98mSeDhg4UAcWXXy7L/t6L2hxekn8JKno7ue
2/EtiusrrNhHOQIYMdMw2MFnF58ENAKBcm5daY0SSGfvujNpPJg8d00oDOFwaWHD
vNCssU+sC78lq1O9BqEFw/dgM/v9E8knK5/katpcYphIcdsCTC3iNhSLCCn0EkgZ
0aXABU6sHlN9Vx2WnDoHFBIzlVksPPuBAhSdVBv6geL+Z3wDUR+n3IolpGDYOB34
+N9IHfbniXeM/621TOJ+ieKgO9xLQ9sqJ2x/KgSFumMV+tV/G1T34gWbbrpbGygW
SDbuWKnIX4TaTC4cAcnAvR4Gv7Cua8uaY0j/uBXhV1X70ZugNnHXbTo3x/YNSXJ4
j+idEmmej0AS/LC4qcESAlbq1qlfHLSt2tu1mwkolvYE7kQUEjQD3XZhWKiRUSht
FRKnEMW/S+AO0XiTtvDyu3CyYzzWLbJmrHy9WaElrRAIITOw9J/QYpKMzVZCi/ju
+km3vL1clU1Dux/JxvHoPcZe/G6O12lp2XROA5VX/2zMazu41AG4VVvlt9FhK/4V
/xFiGHVXWufVgdcuVfhi
=Yq0z
-----END PGP SIGNATURE-----

--=-tQBSb+LO1+IVPHZCsqa0--
