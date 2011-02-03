From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH] fixing hw timestamping in igb
Date: Thu, 03 Feb 2011 15:23:27 -0800
Message-ID: <1296775407.2698.10.camel@jtkirshe-MOBL1>
References: <9D02360A-8016-4BCB-B14A-DAFE22EF558E@halon.se>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-w2UnNZ22eDVmaxbVecgl"
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ohly, Patrick" <patrick.ohly@intel.com>
To: Anders Berggren <anders@halon.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:8279 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244Ab1BCXXU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 18:23:20 -0500
In-Reply-To: <9D02360A-8016-4BCB-B14A-DAFE22EF558E@halon.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-w2UnNZ22eDVmaxbVecgl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-02-03 at 02:39 -0800, Anders Berggren wrote:
> Hardware timestamping for Intel 82580 didn't work in either 2.6.36 or 2.6=
.37. Comparing it to Intel's igb-2.4.12 I found that the timecounter_init c=
lock/counter initialization was done too early.=20
>=20
> Anders Berggren
> Halon Security

Thanks Anders, I will add this patch to my queue of igb patches.


--=-w2UnNZ22eDVmaxbVecgl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEbBAABAgAGBQJNSzjuAAoJECTsCADr/EWU9V4H+LTMfuXf86pjLGGjD8BTBlAe
NRiUWubWQsD2DburCuGZ7GsLcsMSmSOffulpGmtGySKRIQ5SMYBkizG1fbYnaxrL
ZHLmeVURqIDul2ExXdNrvGV9PcbqPkpBjriJ5/VmWiJTs5MhopTrsEkBeXRXY8Am
aVn56bNi3GqDnpnCvaAYKd7r3ee01w4jxBI6Ac38ju9PBvIQKe0d0YJdThVaPgQh
WcrLLRXlZziRY2GEpsyJMxxZh6q8Y3jNTHl5aMb6MD7L2xhfqLjJ1Mol6xhbY5/T
CLg7mOecDz2dagsYaHhguhhcpY2nD6bvo3An+wiC0kGCiNJ5D2ukMcqQvsWgDw==
=u2PP
-----END PGP SIGNATURE-----

--=-w2UnNZ22eDVmaxbVecgl--

