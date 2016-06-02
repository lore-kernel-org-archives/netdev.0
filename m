From: Tyler Hicks <tyhicks@canonical.com>
Subject: Re: [PATCH 0/2] Quiet noisy LSM denial when accessing net sysctl
Date: Thu, 2 Jun 2016 11:30:44 -0500
Message-ID: <57505F34.5020609@canonical.com>
References: <1462575854-4301-1-git-send-email-tyhicks@canonical.com>
 <20160508.235620.333454221783238471.davem@davemloft.net>
 <573B271B.30202@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="rQHejdVnJgNVIT9g8JrHpiR2VrmJPmLrO"
Cc: David Miller <davem@davemloft.net>,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, serge.hallyn@canonical.com
To: jmorris@namei.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <573B271B.30202@canonical.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--rQHejdVnJgNVIT9g8JrHpiR2VrmJPmLrO
Content-Type: multipart/mixed; boundary="aGnvucPKK9vO8SEnIMxoMPqIHbgSshIK9"
From: Tyler Hicks <tyhicks@canonical.com>
To: jmorris@namei.org
Cc: David Miller <davem@davemloft.net>,
 linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, serge.hallyn@canonical.com
Message-ID: <57505F34.5020609@canonical.com>
Subject: Re: [PATCH 0/2] Quiet noisy LSM denial when accessing net sysctl
References: <1462575854-4301-1-git-send-email-tyhicks@canonical.com>
 <20160508.235620.333454221783238471.davem@davemloft.net>
 <573B271B.30202@canonical.com>
In-Reply-To: <573B271B.30202@canonical.com>

--aGnvucPKK9vO8SEnIMxoMPqIHbgSshIK9
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/17/2016 09:13 AM, Tyler Hicks wrote:
> On 05/08/2016 10:56 PM, David Miller wrote:
>> From: Tyler Hicks <tyhicks@canonical.com>
>> Date: Fri,  6 May 2016 18:04:12 -0500
>>
>>> This pair of patches does away with what I believe is a useless denia=
l
>>> audit message when a privileged process initially accesses a net sysc=
tl.
>>
>> The LSM folks can apply this if they agree with you.
>=20
> Hi James - Could you pick up these two bug fix patches? Thanks!

Hello - Just checking in again to see if you plan on taking these
through the security tree?

Tyler



--aGnvucPKK9vO8SEnIMxoMPqIHbgSshIK9--

--rQHejdVnJgNVIT9g8JrHpiR2VrmJPmLrO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJXUF80AAoJENaSAD2qAscK8VIQALub8OK6kTN6n0orcjtU6Xkl
YvVjzmGtcQAILqbVad2LO/3dPwn5wlz6LHOgw7mOpITNjWI9e+mwUJScQq7z7adz
3CNiv3bXhm7pgO83sgDW3hcNyRom3wU6+AAgq8h3MWxinE+4KpZo0WwoTZSM2hms
CPZb5ZxXQKMLPM74XbGerWohSWurjWhihWyj3K7tP0nrn8Bqp349BEPiRSVIwJN3
zr2B0b9tZn10kCGGLwWM9S4PJUjVmxRds+VL/LRfc9JvrnHaKBZnUiegzmNTIJ31
irFZHK4BXIc9pYeU7VCNMomquU+sxqGQQ/giZjdnDtSegVAYgSLlUEOnnLxY2yNI
Zz9KGL+fa8d5RiZ5SFe/U9QQxT5q7Jb/seQ1OBnJ9oDGoENmm8jyV77YYwlDiH0j
Yd9i8gdeM9DYwPebm3QNqhJZlzi7OyTsTU+10Lvnx8fS5490aZRC6uNLDJL9HACe
aoje5QfP972D+04SANJR2zs/0nt1BX6kphK+R506EikhC74eWRBvTl0WafWerXz+
3844AGr7qWuaKIso5pyYtHhKvr1DawMmlMrsHff3IK0CEjdP5KJf1BWTzJon6y5/
U6MIAy8Z8j+0ZzgZpKMktLBeSk1fWvGrrYgNCtqEZmOC8Fu1TtEVKmm2griN5cOG
XkUT8m1N2RVr/YlmBaEX
=lVr0
-----END PGP SIGNATURE-----

--rQHejdVnJgNVIT9g8JrHpiR2VrmJPmLrO--
