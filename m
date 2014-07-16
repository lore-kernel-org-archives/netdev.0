From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net-next tree
Date: Wed, 16 Jul 2014 16:43:22 +1000
Message-ID: <20140716164322.472de7c7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/NxFSIUSMY2k5bljjAX4QPYO"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>,
	Kristina =?UTF-8?B?TWFydMWhZW5rbw==?=
	<kristina.martsenko@gmail.com>
To: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/NxFSIUSMY2k5bljjAX4QPYO
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in
drivers/staging/cxt1e1/linux.c between commit c835a6773314 ("net: set
name_assign_type in alloc_netdev()") from the net-next tree and commit
14b596c9d80b ("staging: cxt1e1: remove driver") from the staging tree.

I fixed it up (I just removed the file) and can carry the fix as
necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/NxFSIUSMY2k5bljjAX4QPYO
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJTxh8PAAoJEMDTa8Ir7ZwVMw0P/05jTQh4OobsTpXerH/ebdUZ
zN8LVRvDiK/iyp7UAKp6XXKPoSqTYtm8o6Gj6ZXUGS3gUY5ct9B1DhhSySjQV9Vj
UAr0ZIHlFQ98ks35pyO3lkKQV73nIMpk0ElkNmGpm1d2xdE4y95N/RBYqSLV2Hoo
1EX0apw+YR+o5zs9XOjf9giSBHRyQUQ4eP5v/gTZ/uc2s9m/zhQsns6jauPJXyuY
ckpnqhxwjnd70cFj8zLRCKDmJq5fQp1jCt+lxsCEIAANKR4MnR63q6OflCy20OzR
Rh7nf/NZgWI+iGYGFPQe0/oGibARsPxPFfW5G7B6yLHjMp70Bdiec7URKw09DeLz
7YX4g8IA4xpR+3D5Ly7kkjwupjDcWQhtbYUHFuMLMjTwK3X6OTF7JuJlhWrFMmJ1
zKWeblDXvO2M6lTA41m4+7DUacaRZ2elpdAPYyekalvwz+wWIAlqnS6BWHx6F1uL
PTkGF3/BjC2NgvpJB69rfWIKSzNFNOCBpDxnWRDyzCxPV8H4zlkoycmnE+oVdkOK
SDOMQLknYRXHA9O52VXYe61u5SS7jkQx/d5RGaDLbmn6bLNcTwqpkhIBw3nt7Hrs
oJQUKO4x+oJeTNnRTgDlPvnffEHBe4eoN6mCsoiKCqhq6nz+CkqbmYQ9Ff6Mhpiz
qGcjfQ+3ca1ofMZRp6Vb
=79nJ
-----END PGP SIGNATURE-----

--Sig_/NxFSIUSMY2k5bljjAX4QPYO--
