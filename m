From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Wed, 9 Mar 2016 23:10:18 +0100
Message-ID: <56E09F4A.8010202@imap.cc>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
 <1456945629-1793533-2-git-send-email-arnd@arndb.de>
 <56D7F62E.6050502@linux-pingi.de> <1659125.tHp8H942OG@wuerfel>
 <1457108303.2651.112.camel@tiscali.nl> <56DADA57.9010200@imap.cc>
 <1457340486.2737.19.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="KEAUc6AuPA014B2jCPQx20NhO6aWh8Bem"
Cc: Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>,
	linux-arm-kernel@lists.infradead.org, isdn@linux-pingi.de,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devel@driverdev.osuosl.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Paul Bolle <pebolle@tiscali.nl>, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1457340486.2737.19.camel@tiscali.nl>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KEAUc6AuPA014B2jCPQx20NhO6aWh8Bem
Content-Type: multipart/mixed; boundary="DxNOIBt8GrA1jpJPa5lA9uu0FEUxkiaWo"
From: Tilman Schmidt <tilman@imap.cc>
To: Paul Bolle <pebolle@tiscali.nl>, Arnd Bergmann <arnd@arndb.de>
Cc: Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>,
 linux-arm-kernel@lists.infradead.org, isdn@linux-pingi.de,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org,
 linux-doc@vger.kernel.org, netdev@vger.kernel.org,
 Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org,
 "David S. Miller" <davem@davemloft.net>
Message-ID: <56E09F4A.8010202@imap.cc>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
 <1456945629-1793533-2-git-send-email-arnd@arndb.de>
 <56D7F62E.6050502@linux-pingi.de> <1659125.tHp8H942OG@wuerfel>
 <1457108303.2651.112.camel@tiscali.nl> <56DADA57.9010200@imap.cc>
 <1457340486.2737.19.camel@tiscali.nl>
In-Reply-To: <1457340486.2737.19.camel@tiscali.nl>

--DxNOIBt8GrA1jpJPa5lA9uu0FEUxkiaWo
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 07.03.2016 um 09:48 schrieb Paul Bolle:
> On za, 2016-03-05 at 14:08 +0100, Tilman Schmidt wrote:
>> As a consequence, owners of HiSAX type adapters are in fact stuck with=

>> the old hisax driver if they want to continue using i4l userspace
>> tools.
>=20
> Do you know whether or not mISDN tools offer functionality comparable t=
o
> i4l tools?

AFAICS they don't. mISDN seems very much geared towards voice use, for
example with Asterisk. The entire topic of ISDN data connections appears
to be missing. I don't see how someone currently using i4l for Internet
dial-in (either client or server side) could migrate to mISDN.

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--DxNOIBt8GrA1jpJPa5lA9uu0FEUxkiaWo--

--KEAUc6AuPA014B2jCPQx20NhO6aWh8Bem
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJW4J9WAAoJEFPuqx0v+F+qt1cH/jgHOY97fm2LSQZUDdjPx3h6
QZO+O0eXSljbgg2nzPjELmt0D0Ay43YR4TYjaAmYv46GzT71VqDcoGKYKMynXx1M
r2UH2MaEy12l/Q2DAKJyFgI8oEsXSiZ1sB2arPeS9tm3QN1RE+lbKJ4CqjGILOa3
jKKJKb5IwKAqBZKPcPkxwkYZ2l+DJNqDBt+67jhqMdPSFNQV+miUK9jNBYtzIG4m
W8tYo54cP1B1U1bWuwJyPcWSqjgxD89AgoNxmRu5nIgK82i6ZZp9jaxtc1+W8IdK
v7i8sUHP4h2AD30gTTG0twyE2yhjhZchGSDJf/HDXzx9pMruUHSzojnHhsr40o4=
=7sH4
-----END PGP SIGNATURE-----

--KEAUc6AuPA014B2jCPQx20NhO6aWh8Bem--
