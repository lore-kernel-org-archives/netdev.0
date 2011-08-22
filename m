From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the  tree
Date: Mon, 22 Aug 2011 11:51:18 +1000
Message-ID: <20110822115118.e5d97beb22befc4ba9396e9d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__22_Aug_2011_11_51_18_+1000_gKhHYF+iNKel0..r"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Josh Boyer <jwboyer@gmail.com>,
	Niklaus Giger <niklaus.giger@member.fsf.org>,
	Tony Breeds <tony@bakeyournoodle.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__22_Aug_2011_11_51_18_+1000_gKhHYF+iNKel0..r
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
arch/powerpc/configs/40x/hcu4_defconfig between commit 9fcd768d0cc8
("powerpc/40x: Remove obsolete HCU4 board") from the 4xx tree and commit
3b3bceef26f8 ("net: fix IBM EMAC driver after rename") from the net tree.

The former commit removes the file, so I just did that.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__22_Aug_2011_11_51_18_+1000_gKhHYF+iNKel0..r
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOUbYWAAoJEDMEi1NhKgbs/TYH/01K9djlGn1GqkEH7/cRk90Y
PqyAXfaCqHis+75rBHvFmmXrNXJ8TeSIHkMTebTC7hHsmnAFI8rzUz2c6oynWBTY
iTj3V8jNCn38LICRep5c21rFiVCP6e98pQBNYtBsIFyno1mMgbX8UtjpHCdJYpAJ
WRFyN4PGK5z5+X/qfKIIeZkV8tPXXItBg+XV1o9fnLhowpV1ljmHORgDxU89xJde
WY6RRrCVBmPymvf0nOwTuvpLvjwRcCfNnCSoENLRkgmbWgkaaOIPmm0/fF8xxTdV
Zf5XPNxFQ4WWl+G6O28h1k77CslgRUdZu6NWhaaTCaX8WzN8042TBeRwxMl+3IE=
=WpNp
-----END PGP SIGNATURE-----

--Signature=_Mon__22_Aug_2011_11_51_18_+1000_gKhHYF+iNKel0..r--
