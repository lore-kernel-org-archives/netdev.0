From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 00/11][pull request] Intel Wired LAN Driver
 Updates
Date: Fri, 11 Mar 2011 06:47:31 -0800
Message-ID: <1299854851.2852.7.camel@jtkirshe-MOBL1>
References: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110311.110629.193721476.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-5iLyATGWB/bEuxpHcI5D"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27500 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754076Ab1CKWrd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 17:47:33 -0500
In-Reply-To: <20110311.110629.193721476.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5iLyATGWB/bEuxpHcI5D
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-03-11 at 11:06 -0800, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 11 Mar 2011 03:06:19 -0800
>=20
> > The following series contains FCoE documentation update, ixgb conversio=
n
> > to the new VLAN model, several fixes and cleanups for e1000e and
> > the removal of Tx hang detection in ixgbevf (like recent igbvf patch).
> >=20
> > The following are changes since commit 1b7fe59322bef9e7a2c05b64a07a66b8=
75299736:
> >   ipv4: Kill flowi arg to fib_select_multipath()
> >=20
> > and are available in the git repository at:
> >   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 mas=
ter
>=20
> Does this one actually compile? :-)

Yes, it does.  Sorry about the last one, both Emil and I had found the
issue when I applied the patch to my internal testing tree and I
manually fixed up the compile issue, but forgot to send out the updated
patch to our patchwork server.

I personally double checked the compilation of every single patch in
this pull request.

--=-5iLyATGWB/bEuxpHcI5D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNejYCAAoJECTsCADr/EWU5XkH/1+6nz3nZ+X3Hfzs3XRYE5y7
XygG1KSaRHEkW1XRnBawmRvwUuhzcR5FtAS8bddNUXgWbo7nGeVN2Ulq+CelhiTZ
VrUiYmh3CiPxdwFK1abAlcfbodGt/FRLeg5y9J0YS0yht1L0U3HLB/U4c5a4b82y
gH3tC19VQFgeOfVhGmkiaVsVus5h60Va6WWNwq8qzKREwb398dIyc69kE601oTau
yDLkQmL2L7Y+KcM5M/tmeHjGAath0Od/NqxF50jC8tiRDMaq2iWW4tVL6lsgZerL
oto81aazznW5ZjoiSmKO0FvQUOZC8U0pMDMJ17owMe1i6eroQp0Awr4x4980aQw=
=sKZB
-----END PGP SIGNATURE-----

--=-5iLyATGWB/bEuxpHcI5D--

