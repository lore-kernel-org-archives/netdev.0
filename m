From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [B.A.T.M.A.N.] [PATCH v3.6 06/19] batman-adv: use batadv_compare_eth
 for concise
Date: Wed, 08 Jan 2014 08:06:46 +0100
Message-ID: <52CCF906.7000400@meshcoding.com>
References: <52CCBDA9.8090205@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="Lmqr1f0DQ1OfLbpb69ua0l3uRU4dTPUCD"
To: The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:12296 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaAHHIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 02:08:00 -0500
In-Reply-To: <52CCBDA9.8090205@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Lmqr1f0DQ1OfLbpb69ua0l3uRU4dTPUCD
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/01/14 03:53, Ding Tianhong wrote:
> It is better to use batadv_compate_eth instead of memcpy for
> concise style.
>=20
> Cc: Marek Lindner <mareklindner@neomailbox.ch>
> Cc: Simon Wunderlich <sw@simonwunderlich.de>
> Cc: Antonio Quartulli <antonio@meshcoding.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: b.a.t.m.a.n@lists.open-mesh.org
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> Acked-by: Antonio Quartulli <antonio@meshcoding.com>

Am I wrong or this patch has already been merged in net-next (together
with other patches from this series)?



Regards,


--=20
Antonio Quartulli


--Lmqr1f0DQ1OfLbpb69ua0l3uRU4dTPUCD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSzPkNAAoJEEKTMo6mOh1VAeoP/i02FowknGOtWPmjRfEVt6VQ
P0Sv8OK8Y1LRCQRR/UAZV6lwfV+BNrFhGiJBUF3KSvE78mREsWPqzXIlcOtQWsAt
5nuJ4hvv7nJUKKjuAizgZ0Sl3ENxegLxcWBluD/qJIggkSMNEnUlXx32eupQU49w
YjtqqVgEGwjlbuMcD7BXBMQkPLt2mMPqM+e5OKzYwnSi1WXGue9ftq2R1Lt1qOxl
/A/GZPm/D+GpmNxv4AVu/86+5UWTxKjHrD1Ti6IS/XZntVl//0vFkb8Q7293eGn1
1gb7iF0AJNAD5tqqih+QZSRp9eBMVSCQNHGUjEdNSs4sMEaZg3K7Jm6FGoqi1SoQ
p4VXuPE5yayFVdq9Mnvsp5fqXstqWLNN84mRN+kIUXjRt3uS8XjMjPmcwq2yJUET
EnPDgMcT0bqzuSydmYK8Fq18zkZ3+n4N4ZdZd/3NjoWiJN8j02ulyh4+ReblwWp8
ys0NQhFjjfhbaZghT+5QZvx0BcVAJVEjzdZvuIsQyOjugYHzSfDhtijf0fXe5uIf
JmoUYnZtvtCPA4xmXsgxs9AoVCV3gaGBSg/Rw4Oaj76QgQeMBf3Ka63FOSKvzC4A
rJhtRqIGgLz5NSPECsOMnqCMg7QGIhKbQpgv8NesUOzUATWGEHOyPQtuRBJ7iB2M
HfNYdb6JgSinhN0kxSPP
=t6AJ
-----END PGP SIGNATURE-----

--Lmqr1f0DQ1OfLbpb69ua0l3uRU4dTPUCD--
