From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Fri, 29 Feb 2008 17:34:13 +0100
Message-ID: <1204302853.3938.40.camel@johannes.berg>
References: <20080228014125.GI3078@tuxdriver.com>
	 <97a0a9ac0802281321h6f302865j38a55c6f761dc14b@mail.gmail.com>
	 <20080228.133008.228590007.davem@davemloft.net>
	 <200802291316.59738.mb@bu3sch.de>  <20080229162629.GB3234@tuxdriver.com>
	 (sfid-20080229_163247_068642_2DE700B6)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-0OUbCEfWOG3VFLhZSa22"
Cc: Michael Buesch <mb@bu3sch.de>, David Miller <davem@davemloft.net>,
	gordonfarquharson@gmail.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35345 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbYB2Qea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 11:34:30 -0500
In-Reply-To: <20080229162629.GB3234@tuxdriver.com> (sfid-20080229_163247_068642_2DE700B6)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0OUbCEfWOG3VFLhZSa22
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Fri, 2008-02-29 at 11:26 -0500, John W. Linville wrote:
> On Fri, Feb 29, 2008 at 01:16:59PM +0100, Michael Buesch wrote:
>=20
> > I'm wondering if we can't simply pass a commandline parameter to file2a=
lias
> > that tells it whether we are crosscompiling. It should simply omit the =
sanity check
>=20
> Sounds reasonable to me.

In fact, file2alias shouldn't need a command line argument ...

> > in that case. Is there any easy and reliable way to find out whether we
> > are crosscompiling from a makefile (I don't know the makefile core that=
 much)?
>=20
> Non-empty CROSS_COMPILE definition?

... it can just check whether CROSS_COMPILE is set in its environment.
No?

johannes

--=-0OUbCEfWOG3VFLhZSa22
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR8g0BKVg1VMiehFYAQLfNhAAnQymaIs0eGyXjsJwIZaENjXt6i1UGvqJ
aOTaHVoOhpECpIlv2XWkp9ga58xcLHJbiH5IsHrMM2Zs8o7OCr198G5vTZCKF9Gx
do4v0LbR7/EqRTjYgbbenQ9Dcbc02d9kmYXMPs0tMzPmFFWZcsR3W1lyWdLBaGEf
6htCGI5+LRsoDXjR6cgrPlX3iHd0/Z8hW79XgjtNREQeO7tC3AvQNC0m9D4hKakY
EM5Zkss6Wc/r03Hkr+s2T3sIOdGJDRxA8jrVeQ4UcYEDHPW6PZ7bqtEMdo1Y2Bi9
MzbCGMGoP5ab7JBlE7bgpuYoPyc8GM00HFpACOQPC4J3xrx0IP09AxRDNF5f/L6/
DN5DvJcttFPQtEVF7HdqgpLuc//vcp9f1/XuL36KR1ChSxJ6i/ZsihH45sPUlr9l
s4B0lEYONoga7i5ivfy+/vGuKj5mymXeKqx292pATpsDgXX3YYELj3z4OHXqF3QH
tAmBe2iwbWoZavx8I3pbf2XOOL2Mn1eeZPb4jBSTVEjmXFpDd4gx2aQ0fzwzcMLp
V1RI/SY6TK17ZIqvpxSi0Me1s510fflxCbZtUQYghiAbzTg8QROejXaj87s1SFlB
Zs5c1bCS8vSbFtBgOHdOE9lVnQsvJ4tl8XTa3INsREbJJzGic5aJUY1djo/e3Ct7
+3VS04cC/Ck=
=aFPL
-----END PGP SIGNATURE-----

--=-0OUbCEfWOG3VFLhZSa22--

