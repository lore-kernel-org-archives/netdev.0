From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: Re: [PATCH v2 07/20] batman-adv: use
 batadv_compare_eth for concise
Date: Tue, 24 Dec 2013 13:07:38 +0100
Message-ID: <52B9790A.3040507@meshcoding.com>
References: <52B96FD6.6030309@huawei.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="wkj9UfS6i1tFp3S8mNpPOqKcNUn0KVwGG"
To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
 Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <52B96FD6.6030309-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--wkj9UfS6i1tFp3S8mNpPOqKcNUn0KVwGG
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 24/12/13 12:28, Ding Tianhong wrote:
> It is better to use batadv_compate_eth instead of memcpy for
> concise style.
>=20
> Cc: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
> Cc: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
> Cc: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Tan Xiaojun <tanxiaojun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Acked-by: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>


--=20
Antonio Quartulli


--wkj9UfS6i1tFp3S8mNpPOqKcNUn0KVwGG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSuXkTAAoJEEKTMo6mOh1VH+0P/AwTpJ/kI0JVqnwKOyRcXCj7
61EksRtpWuhKF5y9kDWeIEU/Ehfn1XM5mhQoJCdY5b2ZjpVUe2M5ICVKSWS3R3pp
15stmdrD2EmWhFG0t4GeoIuZUFfqKZ6Eg4s8l3aTkSFSNpSWP5+8aX8aaW31HTxC
Aqq+MV/HSgjtVhreKoIWCYiL8F48Zxw/rPFWXA9VEeDtWjLqItCfcpesPxR5jUmH
S2/71NEE77vQ5wPGg9M6TnfEPIuxPkpcXDDliLF/Q15eKqQBuNs0Z3ulK6xejHq+
XfLR2n6t6wBT4ufI+ruCcwfgyXeTFtbzZUlhq1lAY6zMKZv7CmAP6R+rUErZ0BEg
gjYIKmEa8IltaebNDQSch7oa3d4HE6MhqLPm6jD9OS1O9bdFjftIlvWHTPSGuNKU
vnZANzRIpRgupmhR53Rjx9hltUiWKTrd0pAo9BZWirjpvuYwS8B+CGTlY+Cx9AsQ
9UKTL1kuAM+jnswaxJ/3oa645gMXTPNE7q6T3ttYAeb81kHcROfTG7/ktLcfj2G4
Cg28tgX5nAy71KuPTKHQN8qjyprP0s9G5Cy/xM4s5fI+CuaTDZvB4+5oyQGU6T18
rxQseqhjsqktHUcGF42mEBUZ5my+UsoRklUhSnToncAsgEYrX/asluSFU81ckTXg
EL+sk0zTmrsXpm3Hl+X5
=ClJt
-----END PGP SIGNATURE-----

--wkj9UfS6i1tFp3S8mNpPOqKcNUn0KVwGG--
