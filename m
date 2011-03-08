From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 00/14][pull request] Intel Wired LAN Driver
 Updates
Date: Tue, 08 Mar 2011 13:10:08 -0800
Message-ID: <1299618608.26413.67.camel@jtkirshe-MOBL1>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110308.111137.112604487.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-DfT5VM6jbOOAp6t8WD04"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31942 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753401Ab1CHVKK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 16:10:10 -0500
In-Reply-To: <20110308.111137.112604487.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DfT5VM6jbOOAp6t8WD04
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-03-08 at 11:11 -0800, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Mon,  7 Mar 2011 18:24:54 -0800
>=20
> > The following series contains fixes and cleanups for e1000e and ixgbe, =
as
> > well as support for FCoE DDP in target mode for ixgbe.  In igb, added
> > additional stats for OS2BMC feature.
> >=20
> > The following are changes since commit 541ac7c9b30ee2ff84ad87f27e0bc069=
e143afb5:
> >   bonding: COW before overwriting the destination MAC address
> >=20
> > and are available in the git repository at:
> >   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 mas=
ter
>=20
> Pulled.
>=20
> Please address the feedback given on the lack of docbook descriptions for
> all of those fcoe device ops.

Thanks Dave.

I will work with Yi to get FCoE documentation patches together.

--=-DfT5VM6jbOOAp6t8WD04
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNdpswAAoJECTsCADr/EWUKxwH/1eyIAcAcz2EU9vIhB+5Fvhb
23gjlMAoielVbKLnaJzpGIJbrlwkIK0QXey4KBjFk5coGFeqeh06uivnetHXKpoK
mOjaohJE9nwZMK8sFDW22l3mhAkXdZBJHjUbUg9h1HniVHYXoEKToxBWq62zjcym
+HRKIk/nPkkxcJzjMU9s25Cgs6vMjuOQ/DWE4QbH/+GxM4jTJr46ZTGcgF/ljGv4
oXOYKTigea9sMyTOXrZSMCqE1SxyNHOqpHMoJaUX9smDRG24Yqmqt5hvOHyon9oc
50JYd7gvOVPNITk13qj1gSRVdvuUJ9DXpyb46jyQM8qsEkW4EKVB982sCutMWL8=
=JAr/
-----END PGP SIGNATURE-----

--=-DfT5VM6jbOOAp6t8WD04--

