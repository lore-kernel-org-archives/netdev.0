From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net tree
Date: Fri, 22 Jul 2011 15:42:18 +1000
Message-ID: <20110722154218.addf4f8105e4563cd90a4620@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__22_Jul_2011_15_42_18_+1000_C2RJN7HFYHRJEVRD"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mark Einon <mark.einon@gmail.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__22_Jul_2011_15_42_18_+1000_C2RJN7HFYHRJEVRD
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in
drivers/staging/et131x/et131x_netdev.c between commit 9d846fec22db
("staging: et131x: remove unused prototype et131x_vlan_rx_register") from
the net tree and commit 2e861534ca09 ("staging: et131x: et131x_netdev.c
checkpatch fixes") from the staging tree.

The latter seems to be a superset of the former, so I used the latter.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__22_Jul_2011_15_42_18_+1000_C2RJN7HFYHRJEVRD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOKQ26AAoJEDMEi1NhKgbsLZYH/RT/EwYesXzc6yI3c52DMbpS
JpXj/981k6sx6qqj+tqQbAhbhbjZTuBIG46lmoARFVwiocX5nA77KgGMG05ifpRv
t9/2ysCdYojljWT9lP/uyDVAPuNM768rkz5YdEr1lXTkGQEHZOAs7slH9pXUwVPh
HjDywu/FE0QnJNAdnHUs34J8r6fG83VKvJYpf6aEKuwDo23+HvhF7cTiqa2PxRYm
xO+fJEeCEvuFOu00v1mkMadAIrUQtwAU+p32gJHvil3g4nRN0wEPz5ddMNVtlbQt
bfoOQ3WuajPEXp5g9bvmCOJJ4jdRxz/EI1goY97W/Bkr4VSCCQtmL1u9gYbHLlQ=
=qNy3
-----END PGP SIGNATURE-----

--Signature=_Fri__22_Jul_2011_15_42_18_+1000_C2RJN7HFYHRJEVRD--
