From: Dominick Grift <dac.override@gmail.com>
Subject: Re: Suspicious RCU usage in bridge with Linux v4.0-9362-g1fc149933fd4
Date: Mon, 11 May 2015 19:42:31 +0200
Message-ID: <20150511174230.GE10375@x131e>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
 <20150504133943.GA17043@x131e>
 <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
 <20150504132714.55dca5b0@urahara>
 <CAHA+R7PVpNdqrOHQgHXYRM8io9GZpeucZ_Gk8YNHqQC=f9+egw@mail.gmail.com>
 <20150511131516.GC10375@x131e>
 <1431355986.566.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="FN+gV9K+162wdwwF"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36205 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbbEKRmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:42:35 -0400
Received: by wizk4 with SMTP id k4so115545416wiz.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 10:42:34 -0700 (PDT)
Received: from x131e (217-19-24-195.dsl.cambrium.nl. [217.19.24.195])
        by mx.google.com with ESMTPSA id g14sm23839360wjs.47.2015.05.11.10.42.33
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 May 2015 10:42:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1431355986.566.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FN+gV9K+162wdwwF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 11, 2015 at 07:53:06AM -0700, Eric Dumazet wrote:
> On Mon, 2015-05-11 at 15:15 +0200, Dominick Grift wrote:

<snip>

> >=20
> > This is just a friendly reminder that this issue still exits in: 4.1.0-=
0.rc2.git3.1
> >=20
> > Ignore me if you are aware of the above
> >=20
>=20
> Hi Dominick
>=20
> Have you tried this patch I sent last monday ?
>=20
> I will submit formally when I get a test result.
>=20
> Thanks
>=20

Whoops I overlooked that. The ball is in our court.

Will get back ASAP

--FN+gV9K+162wdwwF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQGcBAEBCgAGBQJVUOoCAAoJENAR6kfG5xmc8XkMAKoR/p/MHkIjTsK3AwUBXDG5
W6Y40DYTBhRa4Ugdjn7RqBavS8uGwP9SQO54X9vVTWyyoUVzeZFTdANtjog5A+s1
puyohO4gtl9TWFax5g41nckuQD2t+huiobSqz9O53KI0ZPkfhNNsWStXaUazM8Zj
yHsFNOgqBWRLItE6e32g6z7mTscr8TCEv62+XbC069r/cY5dQpzBNUl+eKq/3Nwh
7w7MXBKZSo/OLeRdYjc38q10LWB+Qf8Nr4eljLdSHbXFff95lHrag/bsbGw3dEUD
RWNXc5fA4ossxn2iQhfODWC763qZeG8ceTAaXUze3Lu/TDB2EIIi5YiNhDR/wa4R
wKqNDg/Ohdr5EhMsPZS2QRyCtHh2i6bfYawt+7hs0uk34cUHBawwtJjpC2Z4c5WP
9YuhazgMGyT+gLznse9KCJ1sQ2ssnCyXp9wBge3Ulfm7hk/SjeMQD+KysTn0kYHe
lVwr4uOPNw1ZGihFXYVWxcdAoU/JRQAHeTzOdz9nnA==
=TXup
-----END PGP SIGNATURE-----

--FN+gV9K+162wdwwF--
