From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: linux-next: build failure after merge of the
	net-next tree
Date: Fri, 19 Apr 2013 09:34:09 +0200
Message-ID: <20130419073409.GH20819@ritirata.org>
References: <20130419132127.05ea53adec329ca794d62be7@canb.auug.org.au>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature"; boundary="nYySOmuH/HDX6pKp"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Martin =?utf-8?Q?Hundeb=C3=B8ll?= <martin-SHBFXCSm21MJGwgDXS7ZQA@public.gmane.org>,
 Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130419132127.05ea53adec329ca794d62be7-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
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


--nYySOmuH/HDX6pKp
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Stephen,

On Fri, Apr 19, 2013 at 01:21:27PM +1000, Stephen Rothwell wrote:
>=20
> Caused by commits 612d2b4fe0a1 ("batman-adv: network coding - save
> overheard and tx packets for decoding") and 2df5278b0267 ("batman-adv:
> network coding - receive coded packets and decode them") from the
> net-next tree interacting with commit fe8a93b95145 ("batman-adv: make
> is_my_mac() check for the current mesh only") from the net tree.
>=20
> I added the following merge fix patch and can carry it as necessary:


thank you very much for taking care of this.
However, as I wrote to David in the pull request which generated this noise
(http://patchwork.ozlabs.org/patch/237363/), I am now going to send a second
pull request which fixes this problem properly and adds the related kernel =
doc.

Your patch looks good, but I'd prefer to send my already prepared pull requ=
est.

Is it ok with you?

Cheers,




--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--nYySOmuH/HDX6pKp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRcPNxAAoJEADl0hg6qKeOimIP/1OQBmOUOAtmC2ysu94YCdNk
pBuo+0D7b7UtbdsIfYVQoj3EienZBWKB7DTPbWW3dV91/zWt7jG3YJuseVFqSDzs
XYehdFZ1xXkz1VBSj/EBmQcNeyEHRQm2UDYcYvkQxaGIH6lOQ1ChFusyBD+UMQ8q
Ke4N/fsAHbnsHdhv/qrtxg7qom7ZUxiKvXfyzeW/6l5Lc5x6dtYhU7/8mP/wzaKx
iiastd8h5NHhnxGrBQl26SzKiyryS9xInINQWU+ZBeNddnqGo5AHjuACxbpt5z1A
jn8eyGTzL5GyG+ylBKwMoCJPmuzvQ5b6CUIKrY5iFY2iz4h96Ja7srQIdBjeHNYH
o99KAQrFF7pNN9FF0nFMnz3ngA7rh8cHYndgVBANZWyQl0mWCMmbIfnR2w2YSfQG
tGI1I1WujcHs670DQZsIMadg8EWCIASQNfu17efH2QogHqikjjw3MPKeiTkr+JZM
kwYSHvntfK0aY6AkLzUsUlWWMC57EVdHoSgr/RWoRtc6TNcV8C+z4rqfiHdycA27
5G38FdED2KBILvbUSfneE8Za4XSc9gDCVq0D2d3rzhnGDyrvJ6B5q0C7+DH8FTI5
GCJBfzbcOmn/zyw+UHfHQiV/ucF2Msd8/uWVuDjKeHKbm5emHKVeDGns7iAgYe3x
GSRNU2fPoGviSa9pUts7
=GfXY
-----END PGP SIGNATURE-----

--nYySOmuH/HDX6pKp--
