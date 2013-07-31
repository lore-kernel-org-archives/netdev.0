From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH] e100: dump small buffers via %*phC
Date: Wed, 31 Jul 2013 05:32:57 -0700
Message-ID: <1375273977.2877.42.camel@jtkirshe-mobl>
References: <1374751459-17994-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1374837154.32309.1.camel@jtkirshe-mobl> <1375273205.31118.68.camel@smile>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-F+pdMwPNZp92yLKJroHl"
Cc: netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35825 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268Ab3GaMd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 08:33:56 -0400
In-Reply-To: <1375273205.31118.68.camel@smile>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-F+pdMwPNZp92yLKJroHl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-07-31 at 15:20 +0300, Andy Shevchenko wrote:
> On Fri, 2013-07-26 at 04:12 -0700, Jeff Kirsher wrote:=20
> > On Thu, 2013-07-25 at 14:24 +0300, Andy Shevchenko wrote:
> > > There is nice specifier in kernel that allows us to print small
> > > buffers easily.
> > >=20
> > > Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> > > ---
> > >  drivers/net/ethernet/intel/e100.c | 15 ++++++---------
> > >  1 file changed, 6 insertions(+), 9 deletions(-)=20
> >=20
> > Thanks, I appreciate you sending this again...
> >=20
> > I already have this patch queued up for upstream and it will be in
> the
> > next series I send.
>=20
> Oh, sorry for resending.
> I cleared up my queue after rebasing to recent linux-next, where the
> patch is not appeared yet, that's why duplicate was created.=20

No problem, sorry for the delay in getting it upstream and feel free to
ping me next time.

--=-F+pdMwPNZp92yLKJroHl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJR+QP5AAoJEOVv75VaS+3Oh2YQAKOROlW3nNDrJk60qgTCI57w
mJhW7bZdS1jr/Vg/Wf0Pl3hjqtBCajPq8/7hVTpDPUEK365D7do+e9Hzjj08ZTmj
cqADKNebmbPbpxpI3RH5jfLLyCyhiOYTY+xay3kxoQ8nIRUbXhN2lM8xf6B7HeAf
OuapEIdddv88b9kYxHWuTESKCSIOvGe6qbvWw7/BxvGhZDuoXy/4HAvXgobLZytx
CnSeNXOJlKSYiEEPH4RyXdN8nxbsKueC+miFn0B2IGmP5sSGvlZ7Tvm5cSWjQRl4
xs4qmDK9S1enCURH2uJ6CCB7oOMwJTrM4jgG2JE4TRi/hHSQXctbBwKFjnqu5Bqb
56zm8NSAWdJe/cZMlJb8YNLDmG1xBrNang0SLYooJr4Rx8YkjP+bIkh2VRlE+1CA
0Md+XNdA9DWSVc8hwRZtiVim9QrwdOD86tSrHepKAM5NsuRsSehD2tfaPvQDcBrB
X7N3AZ0KM4SqvHs4tpSu6Md9VBUt2aWGjiNPrVj42KvWnfJsGbph8v6QlMs+hIeY
TU2PW3DpW5yN4DhB7xONX6curV35PSoIMQw5VLY6XOOtVrQarV5ZbInv/6Ps/mlc
qz0niihVVNut/bLjT87NjZW8pWCJZ3egyWVN0EYQFxuWsVRsG7Bh+Xjv2MNxotq4
3uKAAMj2k0jB/vyCr+pW
=DkzG
-----END PGP SIGNATURE-----

--=-F+pdMwPNZp92yLKJroHl--
