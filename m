From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: 2.6.25-rc2-mm1 - several bugs and a crash
Date: Fri, 22 Feb 2008 01:40:35 +0100
Message-ID: <47BE1A03.30300@imap.cc>
References: <20080216002522.9c4bd0fb.akpm@linux-foundation.org> <47BC982C.7050402@imap.cc> <47BD6072.4000407@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigEF1905353D0DD7FA78FC6775"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47BD6072.4000407@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigEF1905353D0DD7FA78FC6775
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Am 21.02.2008 12:28 schrieb Patrick McHardy:
>=20
> Could you test whether this patch fixes the netfilter
> warnings please?

> commit 736b33102292be0d75be1e950ca9bcd5361db7dd
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Thu Feb 21 12:26:01 2008 +0100
>=20
>     [NETFILTER]: nf_conntrack: fix smp_processor_id() in preemptible co=
de warning

Yes, it does; and the system also survives substantially longer.
(IOW, it hasn't crashed on me so far.)

Thanks,
T.

--=20
Tilman Schmidt                          E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enigEF1905353D0DD7FA78FC6775
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3rc1 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFHvhoDMdB4Whm86/kRAn4aAJ0RoN1yil24MkFPeoYSoYWM2U8PLQCeLPkR
qLhSqyWd2ariH9j+tacr9jE=
=vSmV
-----END PGP SIGNATURE-----

--------------enigEF1905353D0DD7FA78FC6775--
