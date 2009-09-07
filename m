From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 00/12] Gigaset driver patches for 2.6.32
Date: Mon, 07 Sep 2009 11:07:48 +0200
Message-ID: <4AA4CD64.4070501@imap.cc>
References: <20090906-patch-gigaset-00.tilman@imap.cc> <1252286806.2139.1.camel@desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD186AE84D3A1C12F84327F27"
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	Hansjoerg Lipp <hjlipp@web.de>
To: Daniel Walker <dwalker@fifo99.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752612AbZIGJIB@vger.kernel.org>
In-Reply-To: <1252286806.2139.1.camel@desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD186AE84D3A1C12F84327F27
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Daniel,

thanks for taking a look at my patches.

On Sun, 06 Sep 2009 18:26:46 -0700, Daniel Walker wrote:
> patches 6,7,10, and 12 all have checkpatch errors. Could you fix those?=
=20

I have reissued patch 7, exchanging the "static" and "inline" keywords
as requested.

The other patches I'd much prefer to keep as they are. The "ERRORs"
checkpatch.pl reported for them are results of keeping to the existing
formatting of the patched files. Completely reformatting them would
cloud the actual changes made by the patches.

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enigD186AE84D3A1C12F84327F27
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFKpM1tQ3+did9BuFsRApyRAJ4tTHKus3ztRLVl+u+xccLjaQ6bLgCfSraV
c5zwxvy3a+E3cJOc+5RMOdo=
=Y6NB
-----END PGP SIGNATURE-----

--------------enigD186AE84D3A1C12F84327F27--
