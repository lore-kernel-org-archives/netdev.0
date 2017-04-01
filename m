From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH] net: batman-adv: use new api
	ethtool_{get|set}_link_ksettings
Date: Sat, 01 Apr 2017 08:40:54 +0200
Message-ID: <2462780.uK9AJZJh1Z@sven-edge>
References: <1490907687-11784-1-git-send-email-tremyfr@gmail.com>
 <5459529.jjAg0OrKDG@bentobox>
 <CAC=8w91DZHq4dKzUS=8w1fUvPG_CmT=HT3amQ15-iVgAV23fmQ@mail.gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2102377.nSGi7hxipA";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, a@unstable.cc, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <CAC=8w91DZHq4dKzUS=8w1fUvPG_CmT=HT3amQ15-iVgAV23fmQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

--nextPart2102377.nSGi7hxipA
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"

On Freitag, 31. M=E4rz 2017 22:33:34 CEST Philippe Reynes wrote:
> > Do you know if anyone already prepared the get_link_ksettings support f=
or
> > kernels older than 4.6 for backports.git?
>=20
> Sorry, I don't know this repo. Do you have an url please ?
> But I suppose that nobody works on such backport.

More information about it can be found at https://backports.wiki.kernel.org=
=20
and https://git.kernel.org/pub/scm/linux/kernel/git/backports/backports.git/

Btw. the code you are modifying will most likely be dropped. Your patch wil=
l=20
get rejected because of this. But thanks for submitting the api conversion=
=20
patch (even when it will be rejected).

Kind regards,
	Sven
--nextPart2102377.nSGi7hxipA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAljfS3YACgkQXYcKB8Em
e0Yk1hAA2WM/HUWS0NOzi7PbCPWsjzIM4VPpcTKN7UKWfasm1lgzcWH92r3ZXsvn
z5We3j5vBxamLlJmw4X11O0+EIscNf9miIR6Xei3Ubhkl5A1DAtAYIneRJ5m3TI+
35G5BR0rdYNjCr/IFrslaWKbsuN4ajF5v0/6AuYb7HGDMjiRNt3JXhMmD8M/9i25
Ojp+kS2lNPfwsxyOLzJgyHHFhWOtZ5dUWf53N2G+EVKIDqqKge9F5YpUNB/LBpWh
2F+NdAk3G3KA6+GSkBi1jP8bpM85s5R3w+8rG3o+KJcy/G8oOz2EiIjO4HpmEyas
MfiXGEwD/QAdYrIaqJILCPiIyL+s0Lb3Cm1dqLrRXW0+ht21KdqLtOgRFfEoC6XY
wPeUkdRDO1iEonm6g70ZARPrxDSs1d/3bgZheISSo+73ufDoY4HlhJxPl8Wn7Igv
jWnqjQ+Ykq1yw7QRAJNv74q8yreXLrgyN8EG4+SJRiwLZOkeIzfbnPI9xAqUL+rX
sWGRe7bU5Fjzqo8uefXFGdM6evKnDVt1WKawY1PWqDp47ZFh9wS1kdyRbmtItZm8
IunKwalws0slEZ31tpcLxAccXEN/Zj1JuyK2La65mafpQW3aYVmUICNpOuksOfCv
EaskxI6Z1iBCkCBkB8v0A7JgWHiFZcBmEhseuxU3Mj5cMHKGrHY=
=KOpf
-----END PGP SIGNATURE-----

--nextPart2102377.nSGi7hxipA--
