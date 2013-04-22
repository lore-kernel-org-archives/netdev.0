From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] e1000e: fix numeric overflow in phc
	settime method.
Date: Mon, 22 Apr 2013 11:17:40 -0700
Message-ID: <1366654660.2037.6.camel@jtkirshe-mobl>
References: <1455e8dd5f574fef93377b61cea8b494102091ef.1366638698.git.richardcochran@gmail.com>
	<1366653202.2037.2.camel@jtkirshe-mobl> <20130422175604.GD2497@netboy>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0885632204118397756=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, Jeroen,
	den Keybus <jeroen.vandenkeybus@triphase.com>,
	David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130422175604.GD2497@netboy>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============0885632204118397756==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Br+wbdFK/Wy6V9a1ZfA0"


--=-Br+wbdFK/Wy6V9a1ZfA0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-04-22 at 19:56 +0200, Richard Cochran wrote:
> On Mon, Apr 22, 2013 at 10:53:22AM -0700, Jeff Kirsher wrote:
> >=20
> > Thanks Richard, I will add this to my queue.
>=20
> If it doesn't make it into 3.9, please submit this one to stable, too.
>=20
> Thanks,
> Richard
>=20

Got it, will do.

--=-Br+wbdFK/Wy6V9a1ZfA0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRdX7EAAoJEOVv75VaS+3O1g8P+gKzbgrNophSALOOW/YuiZKC
bgNb8muHZA1xQLT3ay9veYDBNsAgY/OWT1yxhA90eO08avnzggj2y44ySuwzbLQj
XeDZ8cZyv4CJBCfdfdU5rTUXH+GTlDktDPGSvleks6Uwgj64khgkLA/VjMxCTBQw
wajMsNUYV9CHT062YywPy77tmSR0ubopu1pB2KzDkWKdj45qZ2wCXlsTkl/A79b7
BszCQbWiE8Rzs4tTEEiVbFE/S1ejRJC79bttS4E/X53TftrC96oD5iLsiAF2/GTZ
XZ6teuZuUvo8NDGBBA9UESdJUcAiRsN2o2y+He2G5QAYVMmOcd5TrOuHnSYNRmu+
fZuyFr0xVp8VANvYimFY1G3tbxDXo5UQQp1ngXu5QQIvSjZasEfLnJ8lZgF29HV1
BxUBiq0DCgQXZC6Ebxd4ty/Xw8WGIqI+bSBYCN+dd2qerWiymcoBdx9SEuW/3D5N
QTkyycNzEJ6Y6tsETb1yJdbBYJ3JH2bVnzmneOWOllaAougqqX0QTo5cJ7cgY+l8
xO5Gkcvf/yp5/uqHs2XRKHjAM6vi1GsfyLZd96siI7Vrs4LYIf5HbXob9pxMi5MC
RHRmhSemakKsaqdDSxYQ+5GgCGzWwl6DvGT0yrl1mzaMh7+BYecTW02hroLmKtJB
a2ujrXSlr0EtHcNuUryV
=F1xS
-----END PGP SIGNATURE-----

--=-Br+wbdFK/Wy6V9a1ZfA0--



--===============0885632204118397756==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Precog is a next-generation analytics platform capable of advanced
analytics on semi-structured data. The platform includes APIs for building
apps and a phenomenal toolset for data science. Developers can use
our toolset for easy data analysis & visualization. Get a free account!
http://www2.precog.com/precogplatform/slashdotnewsletter
--===============0885632204118397756==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============0885632204118397756==--
