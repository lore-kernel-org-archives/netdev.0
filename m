From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net tree
Date: Fri, 26 Aug 2011 13:47:05 +1000
Message-ID: <20110826134705.0d5b6767777f0af2f8667731@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__26_Aug_2011_13_47_05_+1000_sWr=sN7c3s+ffcaa"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Greg KH <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__26_Aug_2011_13_47_05_+1000_sWr=sN7c3s+ffcaa
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in
drivers/staging/rtl8192e/r8192E_core.c between commit afc4b13df143 ("net:
remove use of ndo_set_multicast_list in drivers") from the net tree and
commit 09505184ec3d ("staging: rtl8192e: Remove files that are not used")
from the staging tree.

The latter removed the file, so I did that.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__26_Aug_2011_13_47_05_+1000_sWr=sN7c3s+ffcaa
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOVxc5AAoJEDMEi1NhKgbsAuwIAKLlOw9PbsFF+yT8i5EkmDGM
fFuIsUUK24VcHtSL7s4tilFHS+W5I/S+hRM6IGo9PhABpsQUf0e3X6VBB5fO29rL
p6H+0tLIremxIL5X8U7epBYnGr//1iFkiZzv/QNha+l/zgJ73U8LyLJYX+E2hLuq
+JpSF+W3FINjlXqG13FBbDkaJXUibd4CxqVShgjp0gPb/zuSA/qcWMqlp1h2ht2M
lH2ukc/MIoc8B/+a1ipMuzFYKyGrOJnnmQXHd+wAc1pKQZyJHNmporwsmy4hasdB
SrDFU3o9oMi+jFB1apj7l9Ia6sqlgoPsUwgKUytYP9NTm/i7XxiNxErqjnKdwts=
=XJ47
-----END PGP SIGNATURE-----

--Signature=_Fri__26_Aug_2011_13_47_05_+1000_sWr=sN7c3s+ffcaa--
