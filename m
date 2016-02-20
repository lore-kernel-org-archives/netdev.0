From: Antonio Quartulli <a@unstable.cc>
Subject: Re: pull request [net]: batman-adv 20160216
Date: Sat, 20 Feb 2016 13:28:40 +0800
Message-ID: <20160220052840.GF5584__39817.724368959$1455946278$gmane$org@prodigo.lan>
References: <1455634888-29400-1-git-send-email-a@unstable.cc>
 <20160219.153718.442738962662787470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="DqhR8hV3EnoxUkKN"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:35198 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752359AbcBTFbG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Feb 2016 00:31:06 -0500
Content-Disposition: inline
In-Reply-To: <20160219.153718.442738962662787470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DqhR8hV3EnoxUkKN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 19, 2016 at 03:37:18PM -0500, David Miller wrote:
> And thanks for the heads up about the potential merge issues, I'll watch
> for that.
>=20

Hi David,

actually I just realized that the patches that will create the conflict
are not yet in net-next, but they are still pending in my queue.

At this point I will wait for you to merge net into net-next first
(there should be no conflict at that point) and then I will rebase
my pending patches on top of that.


This should prevent you from dealing with any conflict.


Regards,


--=20
Antonio Quartulli

--DqhR8hV3EnoxUkKN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWx/mIAAoJENpFlCjNi1MRwBEQAIDXMq5STK4n8ASouQ1SHc0w
xpvmSOEVPe9pdvw59quDCQvYefXJIwBf4rAAgw9qoJVcsMQSSXXz+LLSXI5nyrRj
oBpIJ4W+yqjwpDI7bKNvJ25tVGFLSEHjOlPGzrOwMekLlr8CaqOW1m2I7WOccIEY
uXRs2NfjTFlcIz0TE8iEmjyuMXx8z/q7jKC4KfEOtLHlrfCjfqajL4bMCvjKn+q4
rAVCQcsEWh2pPegsEHVD1EoUbnuGK4GFU6gR3w614qIFtzVXzufdjCzA3ccDfe2I
RmmhIteHAaaVQPp1PcFHE/R83bMDr5gsgPWGvOR2VUrLXK3TQl7XSaLRDCy6NHrh
4wrB/y8iW/pK7qeVwB8rM7YJoRIxqTXtxrwwuuOaiJchxr3bz6Lzt9hWEEnxLsW9
fmVnkJyX7sB87i+GhmmjtRsTqOQt+Z2rZZlq/gCV4L9Up2vfN6OS3JjKn11sbHYQ
qfK68pVT/4vrzOfbFmuFMpsUs0uvjeWAUjibFpdOH8FKDLj4ap/VQdjIXbpuBIB3
wxL0iclJS+gcqUjWLHdiAAiKU1ghB9f5mGcthcUjrvAeL0bjr2bff16ecofvrvJt
VnKuTalksrhleeuXYcShUJQfhLQnH+8UvQtkoI0m59oPZWazYGSxhKHrdpoXhUlH
s7sRhxpOZ5HkWmggR5FA
=7l/N
-----END PGP SIGNATURE-----

--DqhR8hV3EnoxUkKN--
