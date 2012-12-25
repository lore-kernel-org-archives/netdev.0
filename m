From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: [PATCH 20/29] batman-adv: rename random32() to
	prandom_u32()
Date: Tue, 25 Dec 2012 12:30:36 +0100
Message-ID: <20121225113036.GD2604@ritirata.org>
References: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
 <1356315256-6572-21-git-send-email-akinobu.mita@gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature"; boundary="Fig2xvG2VGoz8o/s"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>,
 akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1356315256-6572-21-git-send-email-akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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


--Fig2xvG2VGoz8o/s
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 24, 2012 at 11:14:07AM +0900, Akinobu Mita wrote:
> Use more preferable function name which implies using a pseudo-random
> number generator.
>=20
> Signed-off-by: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
> Cc: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
> Cc: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
> Cc: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Acked-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--Fig2xvG2VGoz8o/s
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQ2Y5cAAoJEADl0hg6qKeOB2EP/3aLU6Z7GKbCDNYiraQ2bjgs
vLxUt44ZuI86+97VNx3k/yVuRbKI+PqpljIGAcGZJAcl3TD3f0VOkvCQt3rcGy1D
+fS0Mu9h77IpQmWXndg76H0Otto92k1ndnmUGhKHT50X2zIxRHyiBjFAH0Nu5TgM
kFoYWHkLeVbEPMe4sBNsjlY44pGwWXGRvCsrqIOdO0A0T64BwGhJCc4M2IiWW59Z
QqkYEQNur5UZ1KEXFS5hYtTkFkxyxQGXKzDYX51QuEaS2fUZxMy4eFfdGmnLa/U9
/eA8bXAbodj3H+g0ZtV+ozs6le1SQ2rg1ihkCQZqnwCaBe6w01NeMOWQjjp+FIpH
QGWCVfDYeWPktR3mqLdED8w1vp+hVKVGbwRr1bbnJChX12UZrl748uU1xYHh8h+z
WWeS9M2mY4x7tNU//j8aIWvrCZeyDKkP4lJtt6LphwDYc3H+7lYRKm0tBu3YBKKR
I7apadEx7xvC6zI94kZDTGxEnnFs11mHLnc9TpgRSzfEHLwmlrHMduhhMNkWpXpn
5KRDGVmglnWqcR6+U973OHY1qveWucdW9ot7RQi2OGP131oRZa9CGDR8ccwjGDyh
+0KGcFkQiPfevtSd89TbmiOL4MjfqNV93XTaaWCyq7iGChmN+kF6xGTO3hA5nf4j
CzGM8O/iteZJAIOgcbBb
=R0LJ
-----END PGP SIGNATURE-----

--Fig2xvG2VGoz8o/s--
