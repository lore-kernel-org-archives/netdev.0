From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool 0/3][pull request] Intel Wired LAN Driver Updates
 2016-05-03
Date: Wed, 25 May 2016 15:12:47 +0100
Message-ID: <1464185567.2762.3.camel@decadent.org.uk>
References: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1464133631.2631.35.camel@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-coc1RkJ2nBHPzdzVajGo"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39091 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751762AbcEYOM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 10:12:59 -0400
In-Reply-To: <1464133631.2631.35.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-coc1RkJ2nBHPzdzVajGo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-05-24 at 16:47 -0700, Jeff Kirsher wrote:
> On Wed, 2016-05-04 at 09:44 -0700, Jeff Kirsher wrote:
> > This series contains updates to ixgbe in ethtool.
> >=20
> > Preethi adds missing device IDs and mac_type definitions, also updated
> > the display registers for x550, x550em_x/a.=C2=A0=C2=A0Cleaned up the f=
ormat string
> > storage by taking advantage of "for" loops.
> >=20
> > The following are changes since commit
> > deb1c6613ec14fd828d321e38c7bea45fe559bd5:
> > =C2=A0 Release version 4.5.
> > and are available in the git repository at:
> > =C2=A0 git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/ethtool m=
aster
> >=20
> > Preethi Banala (3):
> > =C2=A0 ethtool/ixgbe: Add device ID and mac_type definitions
> > =C2=A0 ethtool/ixgbe: Correct offsets and support x550, x550em_x, x550e=
m_a
> > =C2=A0 ethtool/ixgbe: Reduce format string storage
> >=20
> > =C2=A0ixgbe.c | 173 +++++++++++++++++++++++++++++++++++----------------=
-------
> > ------
> > =C2=A01 file changed, 95 insertions(+), 78 deletions(-)
> >=20
>=20
> Is Ben still maintaining ethtool?

I am - barely.

> I ask because I have this series which I
> sent out earlier this month, with no word and I know there is at least on=
e
> other ethtool patch series that has had no response or committal from who
> ever is maintaining ethtool.

I'm going to do one more release and then look for a new maintainer.

Ben.

> I know we discussed last netconf that we should look at possibly a new to=
ol
> to address the shortcomings of ethtool, but I was not aware we had
> abandoned maintaining the current ethtool already before any replacement
> tool has been developed.
--=20
Ben Hutchings
Time is nature's way of making sure that everything doesn't happen at
once.

--=-coc1RkJ2nBHPzdzVajGo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXRbLfAAoJEOe/yOyVhhEJ+9kP/Ru0kL4o/L5DKSpeFVrFsGJe
hMBpwddUdFJjNotgNl8Fmtr7yxf61VhmgSfEM767fRJNgeMbdM0GZTUsdVyq4KD9
/oGjjplwtzIzEa+8rAj9W40rbhY7Qp6KsaKF1NcBwCLgAXA1n7e9hOYUZLS4lO8E
c2nnY4sPRUbqxAZMCx7FsfhoYzyAoQGP+df9ctqQeVsVQtbx3kyrTGvZ2kMLv+1g
6bahTU2QWZqYlQOdBEa2oXHphmyPIV48fq+hunhNlKapK2e1NOddQer0pDXG5jpO
gHhGaYh1AHvXHC2Zah3Z6yo8Fx5N3GKH5xfT0cOTpUwjN38F24aUKzPmBwsCaL81
QAUBJIzU6yS0OLg/byzJfjACaI7z9m3FiDCqf8BUOIXD2NgepT/11/4iq4BoIcRA
2MZFDaWmowmn4rvO7it6giYfcIP+3lVy5vdcv8qN33+KPsCmUa7ZDVj5gQ95FHvE
l8gnMpV+6HQoAWRm4m5J2byKt6TKu3Gw6U34n4XdoOa0O8+DE3uLMnggVvBL9kGC
sWJBCo/0doujGaYZlAOAWymp70++CjAmKuLDgL4KpL80gZ6lHVk7GZ3RZxe/b1CP
8PC8L8zkYLF0WSvcxvXBc1jaSjsvE3E3okbeWkNTpXSsnxBUkzU/fJNB2qWFYD6F
lOPBehq4OI50npyd5/1Y
=Tw0W
-----END PGP SIGNATURE-----

--=-coc1RkJ2nBHPzdzVajGo--
