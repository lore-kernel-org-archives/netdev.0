From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Support e1000 M88 PHY registers in -d
Date: Wed, 04 May 2011 11:00:49 -0700
Message-ID: <1304532049.2998.4.camel@jtkirshe-MOBL1>
References: <20100319043229.24908.99968.reportbug@Feynman.home>
	 <1301761441.10056.197.camel@localhost>
	 <BANLkTik7G82DwhA_EU8KrKJO25+W=yjWFg@mail.gmail.com>
	 <1301910102.2935.52.camel@localhost> <1304530875.2926.29.camel@bwh-desktop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-nfIwJLGfF5KS+Aj5CdIK"
Cc: Anthony DeRobertis <anthony@derobert.net>,
	netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"574574@bugs.debian.org" <574574@bugs.debian.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26091 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755112Ab1EDSAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 14:00:50 -0400
In-Reply-To: <1304530875.2926.29.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-nfIwJLGfF5KS+Aj5CdIK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-05-04 at 10:41 -0700, Ben Hutchings wrote:
> On Mon, 2011-04-04 at 10:41 +0100, Ben Hutchings wrote:
> > On Mon, 2011-04-04 at 01:36 -0700, Jeff Kirsher wrote:
> > > On Sat, Apr 2, 2011 at 09:24, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> > > > Anthony,
> > > >
> > > > I'm now upstream maintainer for ethtool so I've picked up your patc=
h
> > > > again.
> > > >
> > > > On Fri, 2010-03-19 at 00:32 -0400, Anthony DeRobertis wrote:
> > > >> Package: ethtool
> > > >> Version: 1:2.6.33-1
> > > >> Severity: wishlist
> > > >>
> > > >> The M88 PHY registers contain useful information like the cable le=
ngth
> > > >> estimate and the MDI/MDIX status. The attached patch makes -d dump
> > > >> them.
> > > >
> > > > Patches for ethtool should include a commit message and Signed-off-=
by
> > > > line, as in the Linux kernel.  See sections 2 and 12 of
> > > > <http://www.kernel.org/doc/Documentation/SubmittingPatches>.  They
> > > > should be sent to this address and to netdev.
> > > >
> > > > I'm forwarding this patch to netdev and the e1000 developers for re=
view.
> > > >
> > > > Ben.
> > >=20
> > > Thanks Ben.  Just to be clear, have you applied these e1000 changes t=
o
> > > the ethtool?
> > [...]
> >=20
> > I have not applied these changes either anywhere.
>=20
> ...but I will if I don't hear back from you soon.
>=20
> Ben.
>=20

Go ahead and apply the changes.  I apologize, I thought I had already
pushed this patch.

--=-nfIwJLGfF5KS+Aj5CdIK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNwZRRAAoJECTsCADr/EWUCqAH/1K8oqKs009iFslJ2T5FSqnB
fneP0GKKzfZ1GjTGM5SWnOkgogMV5keWCaPjcbxTBZian6KCEPqxCpEX8+4SJS3C
7Mp2S9LyfIg5WzjcjDaGChomvX9FR94qCiXHtFJBnn3U7s2xRFqF3FAMbz/AfB7f
BM15vxNFPH36IkFI76yNYu89CSU2MtXvuDn08smgf06kXFv7N+YVOVdwQxkqD3jx
j3CuRJRto5IBq+It/QNQJWtOgMTUz6/zTYVDdEFTObuvzAGPrFc5plyHIYiunp6P
aiIJCPwXX+mcaCyqxIx/kghm2v0cocHvJ9Jan558EL5mXnvgO5V2OOAqV1Td3SM=
=jZ3a
-----END PGP SIGNATURE-----

--=-nfIwJLGfF5KS+Aj5CdIK--

