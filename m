From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Tue, 2 Apr 2013 13:00:44 +1100
Message-ID: <20130402130044.ddacc1c990698bd416e4c808@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__2_Apr_2013_13_00_44_+1100_n7=e+wvFFUabKbTr"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Samuel Ortiz <sameo@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__2_Apr_2013_13_00_44_+1100_n7=e+wvFFUabKbTr
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/nfc/microread/mei.c between commit 9593b0b1179c ("NFC: microread:
Fix build failure due to a new MEI bus API") from the wireless tree and
commit 63cd353c34a0 ("NFC: microread: Fix MEI build failure") from the
net-next tree.

I fixed it up (using the wireless tree version) and can carry the fix as
necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__2_Apr_2013_13_00_44_+1100_n7=e+wvFFUabKbTr
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRWjvMAAoJEECxmPOUX5FEYecP/RWmvNmN63kf5X/6ZfzZj1aw
RccbsO9QE2oZ0ROjy2SAFFv1v0XCZm6ekavdwrmdVnGzaHmYOjzBCZHYm5JI6SP2
3X9URm7ATbLiXMbIZB5XOkRUbx2X8s49M/ZPJ5Nwd49xNvizi/kn6q369Feds9v/
2RQ955B/Cvp7CgoUCAv1TsTELnwgWowyFZ3TXv4UKxMsYF1mYzruD9R2n4TJ18mg
BQPJdlO8nU3bkLIPByMmRDLFqFJQZPHTgPyHBP25g3nPT01KrCHc2104gHM/GOR3
zIcOcrstIMg2CgjPGuBqktMFsVCMLCMpeSXMi8m8dYi8/7DrrXrnDjfsyjRS9HCL
D7XL8mEXyOBL37HKXC/t7vS9/1D2/fGN3HiYIB/ZHcqQyp45AvyQiRQ9+wYlGWBC
k9q+USQSGkNUiUSHjnyHur3Ao0S1dGRGmYC0WBnKqjEwJ+ouReovziDg4ifzBU5X
lEAVODT0O++rJAirTjyRDsVKJpwKlL18/FAdD5jYUdZvWgIY+KC4/lJ3fUzYRqko
7kHaw8qtqLhzxd3X16oHnOI8OUkn5PfywrZwNsLUCDVX3pXFAarzUh2xSTzSboq4
Yk0JhO0cl3A+EjMbq3hlkJcEjMZUfLXOVQJ/NIGoeKeqB+ECIklY5enGgsQycT7S
27Et7rNfZ0cZ6oI0vzdq
=ABY3
-----END PGP SIGNATURE-----

--Signature=_Tue__2_Apr_2013_13_00_44_+1100_n7=e+wvFFUabKbTr--
