From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/2] net: can: remove unused variable
Date: Tue, 18 Nov 2014 21:39:00 +0100
Message-ID: <546BAE64.7030406@pengutronix.de>
References: <1416318427-28676-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="2SIFd2A4enKJhnqeVUJotQIuriOILaqj9"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416318427-28676-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--2SIFd2A4enKJhnqeVUJotQIuriOILaqj9
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/18/2014 02:47 PM, Sudip Mukherjee wrote:
> these variable were only assigned some values, but then never
> reused again.
> so they are safe to be removed.

Thanks, I've applied both patches.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--2SIFd2A4enKJhnqeVUJotQIuriOILaqj9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUa65kAAoJECte4hHFiupU4k0P/iJTMIH/d2Shj0PibwHfTbz/
oz5DalefJNoxkaMcmbpOMHRn27KwJijCbn+G5Dgy5HA7kKp1Y2fkITqjlqlwS5AE
z5jH4zXDW4IzzsloZhy1XSLzVW56UIh1H8lcd2fyLNn8Qa+QQ25/QxRTLtokKXXx
TBwrK03yjt3R9Mj1pvaoc7yUSYxLChjvoYl9i9bVh9xEeQLj3wBP0KdJmjxWnd1Z
Sq6AmuZXrIi2crNeBoQCCJZwYEPr60UCDKFpltjHjcWk3eZKHNE4kkEj2jef39dn
jBmclYsPh5UINByZK4Xu+nDo0cFioMXyd7CcjghRfqYOfrueWOsnDT99UrWpd5XR
2TDHSOF0qFxN09+RdPBHe70e0ONfiTJHIQvBNEG3AVyFJxrkFqAfDZYzTVmB4re4
xe8L4S0U+yyuOmwadrHHnPpJXHazABBmv9Va2uFOU2bigSnWWLU82rlHFLgyqlse
qxhve57jq/t2VR01q/5HjbUQvuJ9VL1FJPo5lt9r9aA4GufZ1ZLRnKnFYe0G4LJ1
xpo43iWuuxt6xOYl8WXCmQOc7mvmuFsKAPOkw+ojO8uOq5WewuTgEbNpJjbDE9Pw
Eq6xYsCs9Dc643wlSxS7JAY0/VvItDeXwAWWCSaL58zIQOIUFleOxodFrTsKv4Cx
Xb8jeYEoQiPVB4snH/2t
=NaXV
-----END PGP SIGNATURE-----

--2SIFd2A4enKJhnqeVUJotQIuriOILaqj9--
