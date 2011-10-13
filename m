From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net tree
Date: Thu, 13 Oct 2011 16:43:53 +1100
Message-ID: <20111013164353.09c495e1b63d23e380cca1f7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__13_Oct_2011_16_43_53_+1100__cd91dPJ13Bc48dn"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arend van Spriel <arend@broadcom.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Jiri Pirko <jpirko@redhat.com>,
	Eliad Peller <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__13_Oct_2011_16_43_53_+1100__cd91dPJ13Bc48dn
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the staging tree got a conflicts in
drivers/staging/brcm80211/brcmfmac/dhd_linux.c and
drivers/staging/brcm80211/brcmsmac/mac80211_if.c between commits from the
net-next tree and commit fc2d6e573be6 ("staging: brcm80211: remove
brcm80211 driver from the staging tree") from the staging tree.

The latter removed the files, so I did that
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__13_Oct_2011_16_43_53_+1100__cd91dPJ13Bc48dn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOlnqZAAoJEECxmPOUX5FEVvMP/1GUqQdKC7EsKL/ldG9jNtsj
GsESUdKVgCJgE6Ab9MEXfsSf+K/mZvwMh+tZb6DUxcFpDFypULzPwwZ7qRRH5jCb
G0sNCGBJe3GN0WZTui3KIUurljkfIPmcBx9reYuZRv9QFta/vHQAh1f+QMKeI4Ye
u0MqdlWAsw3k1II8pBhil2FH0lIOUeAKCQt5b7kJFXMr/+r7Horoea+O0couyefc
svnaxIaNhBZTImXNqyFuxOP8qdQD6vV+hq3TT686U0t98g06ly7vbFx4QbSxzZex
5tjwBL+npzdnoVyJIp4zIyUwbbWlfItyGYEGXVlLGp6fmg8fmp5qQ6LHN00GpM7k
2eSy+DYtmXcJAdxH7YyLtlFCMFrfA9GaByI9An2dmC0/dRX+REhBHoQslIOoiu4u
C6X/JCw5k1FeO/Pe2SD91k5vjfa+bMbK/M3G3VFYfcgIuYZYxXVi2Ol3MkEMpO+j
pZHaO3PUQVn6roSwi2p9zxMmrDmkVLfIKO7W3Z3SiuijRsSOfalOL7zZ/+3yP8sz
r50kS2h27fviUWN0RDSaAHh/SPNDJhATKOLzVWvfvQU+GFnQ03zNtG6BSJXm4hIs
d/wBq6Ogq4nCRSnVIDoAw8Rhjv4xYqBD9TQtywknDYP6qeCZ/15fp3xvA8dUejMi
d8fi6mEf5E1iozX+epgf
=PZPQ
-----END PGP SIGNATURE-----

--Signature=_Thu__13_Oct_2011_16_43_53_+1100__cd91dPJ13Bc48dn--
