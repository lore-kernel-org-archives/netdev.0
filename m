From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: [PATCH -v2 19/26] batman-adv: rename random32()
	to prandom_u32()
Date: Fri, 4 Jan 2013 03:12:53 +0100
Message-ID: <20130104021252.GE27589@ritirata.org>
References: <1357215562-6288-1-git-send-email-akinobu.mita@gmail.com>
 <1357215562-6288-20-git-send-email-akinobu.mita@gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature"; boundary="wTWi5aaYRw9ix9vO"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>,
 akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1357215562-6288-20-git-send-email-akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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


--wTWi5aaYRw9ix9vO
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 03, 2013 at 09:19:15PM +0900, Akinobu Mita wrote:
> Use more preferable function name which implies using a pseudo-random
> number generator.
>=20
> Signed-off-by: Akinobu Mita <akinobu.mita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Acked-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
> Cc: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
> Cc: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
> Cc: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
> Cc: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---

Hello Akinobu,

as you can see in <201301021952.49979.lindner_marek-LWAfsSFWpa4@public.gmane.org>, Marek Lindner
already applied this change onto our tree. You didn't need to resend this p=
atch
to netdev, it will be sent by us through a future pull request.


Thanks a lot.
Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--wTWi5aaYRw9ix9vO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQ5jqkAAoJEADl0hg6qKeO4/wP/11xG2Bo310vl+gCHHVGJL44
e0vYKg/Jpb89sjXerAhAAUzVodMLCoUz/35W6ix8RJtzCkU7b6PCIe25eZtbfvIW
VLnThzhzwrKaXvbsIgydtqOXaMyhjdytkZho0UAnAn8AT39qv+M4nBvjjFFEvs/T
rFIXz9gz7Q7y0CzHxT/3ITRUvE9x8/8aMGcdMsgOmmo8ELQiHa45/cwumUHutVif
dOnK2sSO1GKVQeWG9LkhbCmjY6A+si/q59A4bIcZAi5v75kNqastbi9fm4/G/LuY
gP+g+MrIle9h/bPnrCvjPNHsUl9qcZuFJQEtpuuOIISbqmMKVM63yWeZ8W7+oVc8
lT2NY+uR2gYG0nk3OM2mi9SWqtyh9cATr2dP6nLMlYIDCw3JwqjDqkz1/8BtaBQB
v5gk29b0XkKQ7znoPQGSnBCzHoq91JNsXhLrvEJH0i7DdYGtzTgvU8E/NLSHib7p
D0EU5j37VbgTZW/Ul6Luds4T+slY5TSU9H0NIoSFNkYQtDxK5kDabys4s63r9WKC
AS8Nv6BRxitTTRl287RL18VZQCDsFAdb+hFgKwF5AL8t8FoKCZjpqOLiKTWj9CRs
cLwIEQc/+RCfouG63YW1boXRH/ck4Lt+KKmhHZWHgdf0Zmk0BNkw9uUZ4jAGrM7e
wh3HZikTXjjjc4RyuL6d
=Mkl9
-----END PGP SIGNATURE-----

--wTWi5aaYRw9ix9vO--
