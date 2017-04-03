From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH] net: batman-adv: use new api
	ethtool_{get|set}_link_ksettings
Date: Mon, 03 Apr 2017 19:00:17 +0200
Message-ID: <1838624.A40jRuP0qt@sven-edge>
References: <1490907687-11784-1-git-send-email-tremyfr@gmail.com>
 <CAC=8w91DZHq4dKzUS=8w1fUvPG_CmT=HT3amQ15-iVgAV23fmQ@mail.gmail.com>
 <2462780.uK9AJZJh1Z@sven-edge>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart5943313.cPlmt3QUqU";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, a@unstable.cc,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <2462780.uK9AJZJh1Z@sven-edge>
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

--nextPart5943313.cPlmt3QUqU
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Samstag, 1. April 2017 08:40:54 CEST Sven Eckelmann wrote:
[...]
> Btw. the code you are modifying will most likely be dropped. Your patch will 
> get rejected because of this. But thanks for submitting the api conversion 
> patch (even when it will be rejected).

The patch was now marked as rejected because a conflicting patch [1]
was applied. The code, which your patch modified, doesn't exist anymore.

Kind regards,
	Sven

[1] https://git.open-mesh.org/linux-merge.git/commit/e2790a4b275d52e332e0ad71b5f2eff53fe21805
--nextPart5943313.cPlmt3QUqU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAljif6EACgkQXYcKB8Em
e0YRshAAvOLj+zKFN25eKYP0ZMmcVvbWaji38Am+0cVr01WbF3s/ozgxBLoMJlVw
S0BNplA4G1wRQ4vwglMCF+GbPi6WkfREmS+RMTEtTfoEGZfntUtqfPKhfS+SAZ70
/X4XG7j9JKC6rroDaw08koSHMFU9wPIU/mu8ue7hTx9FFYC5Qktds+5dTHgdr0DV
J5Ni5jx6Cr0DIrgDbSv+LLIm3dueG2na2xOYIEASUYGvoc1hmy30sOHXD7+h8Lnh
YpvpCiJL1KsVo+O1waN70y3oX7OS5J3ouplL0cuRco/KkTLsyX0JvcWx356jkGDE
tW3j8MJz5eJCZ6EQpIaVgJQnTLzWa6fYssdJJihVqGe1m3yRXgxMfOvE2iIkFUCK
/IBscY150yp+490BXT2u3jy6Rh+eemwpXaJYx2SjVHoakFBb9C2vneLqNgcTa5jx
PTKJLTsp+UfTj+qjhhFOTYNJjfen85V+fDPa+WsY5DCBx0jPlH/xqKXilHAx+9Xf
LPeiVCEIvUPGHVHCxJEkqkvuugIBwS9gVjT8sSiFm+Hm03xdQS/nhZR6sRyL2W8V
swd4ojses3qrV9il3mW7eqTk0RO6GJ0uLg1r+VTkmBFx1QqPISiXjzWf0jNZuky/
8b7kpeEPEnX8SZ6juL9N3ZWUWaBJtgsuBKvqa4bD6SlbMvmYwQc=
=y63T
-----END PGP SIGNATURE-----

--nextPart5943313.cPlmt3QUqU--
