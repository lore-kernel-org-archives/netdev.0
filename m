From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH v2 2/3] if_link: Add VF multicast
 promiscuous control
Date: Mon, 09 Mar 2015 19:48:15 -0700
Message-ID: <1425955695.2579.23.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E53671@BPXM14GP.gisp.nec.co.jp>
	 <1425952344.2579.20.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bVqqnjWu+/AtVjRZvW3X"
Cc: "vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	Edward Cree <ecree@solarflare.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425952344.2579.20.camel@jtkirshe-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-bVqqnjWu+/AtVjRZvW3X
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-09 at 18:52 -0700, Jeff Kirsher wrote:
> On Tue, 2015-03-10 at 01:42 +0000, Hiroshi Shimamoto wrote:
> > > On 03/08/2015 02:15 PM, Or Gerlitz wrote:
> > > > On Mon, Feb 23, 2015 at 11:14 PM, Jeff Kirsher
> > > > <jeffrey.t.kirsher@intel.com> wrote:
> > > > [...]
> > > >> We discussed this during NetConf last week, and Don is correct
> > that a
> > > >> custom sysfs interface is not the way we want to handle this.  We
> > agreed
> > > >> upon a generic interface so that any NIC is able to turn on or
> > off VF
> > > >> multicast promiscuous mode.
> > > >
> > > > Jeff, please make sure to either respond to my comments on the V2
> > > > thread (or better) address them for the V3 post.
> > > >
> > > >
> > > > http://marc.info/?l=3Dlinux-netdev&m=3D142441852518152&w=3D2
> > > > http://marc.info/?l=3Dlinux-netdev&m=3D142441867218183&w=3D2
> > >=20
> > > I agree with you that the patch descriptions should be cleaned up
> > and
> > > "beefed" up for that matter.
> > >=20
> > > If/when I look to push his series of patches, I will make sure that
> > your
> > > concerns are addressed so that we can get a accurate changelog.
> >=20
> > I see that the patchset should have better explanation in changelog.
> > I will rewrite it and submit again.
> >=20
> > Jeff, are you planning to drop the patchset from your tree?
> > I just concerned which tree I should create patches against for.
>=20
> Yes, I will drop the current patchset in my queue.  I am in the process
> of updating my queue, go ahead and make your patches against the
> following tree:
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
> all-queue branch
>=20
> If you give me an hour or so, I should have my tree updated with all the
> patches in my queue currently.

Ok, correction on the branch name.  After doing some cleanup and future
planning, the following tree:
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
is what you want to use and the branch name is:
unstable-queue

The branch has all the patches currently in my queue.

--=-bVqqnjWu+/AtVjRZvW3X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU/ltvAAoJEOVv75VaS+3OIaIP/3GOf6ekVjoE7DMs6xiliTjw
7zk1DOclDSYxcHV4ZufzeUbSKt4KOIS5dsPTT/9octt0Iqj+aBY4r42ShucQM/43
kHHIjylHuIRCHn8cN3Nxo1o0UugUF0wSvSlvUyzvrdAH2WeExBPkcaUh5KaSZ4/t
/L1SaTRXqzeOp0KQ8oKTWHQaZ3lv3qoJHkFW0FnjLYirZlKHOB0cgV7rnsOnXiGy
4GEXRNOd8RcvDSVA7nbmywEJLh0pcqLfXgkBXlekcUolzCDGH/r3BoPBecc09Gu8
hpIO+DlLjyVTdAjL5L0KvJdS3ChISiitgeHWb/2Ncn0w4rEfE4sTPfDKiVRX3VDU
C6LJPMc1VGVLpcSJSrnrfLdY4au1jlmTlajyiiI1baZTiIKbjtaDgFVhvuTf1bNW
cS4p4DTKz+BSbhy3IcyJe8k5aCBMuzEf6o9AHNexZqTEvNhkrSQ6t/bWSoMtcHyT
PQmZVz0TcDjH3NdbskhhYIoQXo2kaOvF4HUxi/y13b9D2vi9EBJVPQo2CDZVJ1sw
LjdkjBB0Q4hK91V0DeiP1eX21Xv658rIRgf1583FA1lSMIUsWVscapxUH5+njR7d
bIvvmlxTcXxhJtMAmvIjNp6IjTz1GJTAFdUsXL+DjHhahzFLk1noWYKSyj72tT0/
c7YdJ8rAShPMjROV+9j9
=xwQD
-----END PGP SIGNATURE-----

--=-bVqqnjWu+/AtVjRZvW3X--
