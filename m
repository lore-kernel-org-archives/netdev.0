From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH 0/2] batman-adv: Fine-tuning for three
	function implementations
Date: Tue, 23 May 2017 12:14:04 +0200
Message-ID: <17596488.icP3obENQD@bentobox>
References: <512d2e7c-0967-9303-2b68-6c9ef53d6ed2@users.sourceforge.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2267927.tk46vfJtNm";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Antonio Quartulli <a@unstable.cc>,
 LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <512d2e7c-0967-9303-2b68-6c9ef53d6ed2-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
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

--nextPart2267927.tk46vfJtNm
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Samstag, 6. Mai 2017 18:12:46 CEST SF Markus Elfring wrote:
> From: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> Date: Sat, 6 May 2017 18:03:45 +0200
> 
> Two update suggestions were taken into account
> from static source code analysis.
> 
> Markus Elfring (2):
>   Replace a seq_puts() call by seq_putc() in two functions
>   Combine two seq_puts() calls into one call in batadv_nc_nodes_seq_print_text()

Patches applied as 626caae9f257 [1] and 912eeed9f520 [2]

Thanks,
	Sven

[1] https://git.open-mesh.org/linux-merge.git/commit/626caae9f25746c39b0a1204f8b8f532c1746f10
[2] https://git.open-mesh.org/linux-merge.git/commit/912eeed9f5208515b75103e91ff8b64cfdcca7b9
--nextPart2267927.tk46vfJtNm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAlkkC2wACgkQXYcKB8Em
e0bTDw/+LCVRYOqMsNF2I928UxmdREyqpsXD+bDvDwv9LCSlHjlANMP2Pd3p1isJ
LuOIct85wgbPfeloYhxbvSiul7NCzpzye+FdqvCIEP5Q3n2DU0EXeS38naH/mg5l
T82t6o8B5gDbYowU4AeUAdPNTn02i7PU1I/hLtWG7q3oKuufWLhytsZWY7jbjhMm
dH6Ko8O9uzCxoEUHjjOxOKKV5uvySaYNbzIsQ20pYDbFDhJcwwc04jCQyPdqb5Pq
E/gVxuhBdruHrL0BJt/dD/XLd3FQAVamb93WHrmtnKmUL9jsr6JoFSl66uui3ciJ
Wc0NoI5X4UE0yRmzPONe0WflxRvI9dZG1BxfuhUqqU+SbwULna9zSvYdEJ+pOxCz
rYzGErwpUDEEsb+Qs/p0nrYLihRS00lbeQaFmNO7s39/Tq+bJY/poDS6h6D+es97
V4C49XACCIgTCUKo+XCpToArHnwGwHQiBRyBeO342vZ0kvFfphFsI7BCW6wnEa+C
39xPFmt6QhdB1x84uFnhIIKbXBKNlkBYqPbf2uA7T2EFxixTbjTYdQr4CM7uaKrd
r14z6snctYp0VYKtQaY0btqET63OVYrE1pKof6nE4GZ574HoUKyeD1P+S3hVKj0m
OUFwBmzyT3/rQHSXgM0lAZ/jNo00GQkjLYa5NHcjw5+vI9yDVqc=
=q8YE
-----END PGP SIGNATURE-----

--nextPart2267927.tk46vfJtNm--
