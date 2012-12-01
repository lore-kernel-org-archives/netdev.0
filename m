From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH 6/7] batman-adv: Allow to use rntl_link
	for device creation/deletion
Date: Sat, 01 Dec 2012 14:39:26 +0100
Message-ID: <3895612.sgriB1OUoY@sven-laptop.home.narfation.org>
References: <1353715332-4284-1-git-send-email-sven@narfation.org>
 <15221362.NFC3M7kpXE@sven-laptop.home.narfation.org>
 <20121201132802.GM24115@ritirata.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1377346.UzvJhltQ9E";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
To: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20121201132802.GM24115-E/2OGukznS5g9hUCZPvPmw@public.gmane.org>
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


--nextPart1377346.UzvJhltQ9E
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="ISO-8859-1"

On Saturday 01 December 2012 14:28:02 Antonio Quartulli wrote:
> > Because this is the normal way to create virtual network devices (please
> > feel free to correct me).
> 
> Well, I've seen different iface types using many tools, e.g. vconfig,
> tunctl, brctl..
> Not that this justifies the fact that we should do the same (imho having a
> standard and unified way for creating interfaces would be the best option).

The device creation and enslaving using vconfig, tunctl and brctl can be 
replaced using ip.

> But, to be honest, I think it should better discuss how to entirely
> moving/changing the existent API to a "better one" or to a "new one",
> instead of starting to maintain two of them from now on with no plan, don't
> you think so?

I leave this discussion to the maintainers of batman-adv. Btw. removing the 
old one without a time of coexistence sounds like a bad move. And therefore 
maintaining of both interfaces like it is done in other network devices seems 
to be necessary.

Kind regards,
	Sven
--nextPart1377346.UzvJhltQ9E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQugiOAAoJEF2HCgfBJntGWjIP/in/ncBHssYGHQg1yWKixL15
Nd1eepJwiFHvTECaUH56ZgeaVve60Dc9CS/xzsI2H+rhwxfe0lvcAyICuZZ4qyY8
TU913ECdUsX6gPxcy2IUScqeUd8SuyX2rHlYhFv2B2deZrvjwy7aNnqsSo/8Qq/r
L/3EbNdbuSLiWSmDB13WKUOwFJMueO0vK4kk6e3UnY1laayX9VDx1wNwCHjriK9B
TijexhL7FBHPyGccUp5oGQPjXtGN6NYePAx+Fbf4LFsCYzT84HekhsMmuKYTS2xR
3fEqfUcoqB9/Dr89BTK7H/EQuUT6z/nw16H8yr4cQVE0dHuGQaynE+ufSCV5jukM
R0clTiMFpmphtxK6UN3c/UcLDv9L8gTB4cWYg2m61Tx1qo/V0FOfP3/lF8JMdakw
w0D3o3S72s+7z2vis2jJl2kKRTVoP+8j0BPHGdjEz0OqZv1eoeJvcdn0CgHiHiTA
fYeD8Rdp5EWBg959He51v8iuBE6MeTaKMS2QFAC+art1XxCVKXLCM9bmWvGJ5jwc
Rflx8CaaYDQ4zHniyL3+xffGK7AQLl0pzuKMO/1WYWwhZMoI5uqw6t3QinRKz5kb
bKrD/f2LQSBYXfupybWC/XvpC3PO4G0C3ySXcnuyBIKCqraiH6C6F7SEnBmHPq7y
nYOoNPN6IRjQw3QUKHCh
=NDgk
-----END PGP SIGNATURE-----

--nextPart1377346.UzvJhltQ9E--
