From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the ipsec-next tree with the
 net-next tree
Date: Wed, 25 Sep 2013 09:59:19 +1000
Message-ID: <20130925095919.143635403832766c1b190202@canb.auug.org.au>
References: <20130924121629.f818475ddf308b0494cfce2a@canb.auug.org.au>
	<20130924102505.GS7660@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__25_Sep_2013_09_59_19_+1000__nzaazIW/4Ty6+L+"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Fan Du <fan.du@windriver.com>, Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130924102505.GS7660@secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__25_Sep_2013_09_59_19_+1000__nzaazIW/4Ty6+L+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Steffen,

On Tue, 24 Sep 2013 12:25:05 +0200 Steffen Klassert <steffen.klassert@secun=
et.com> wrote:
>
> On Tue, Sep 24, 2013 at 12:16:29PM +1000, Stephen Rothwell wrote:
> >=20
> > Today's linux-next merge of the ipsec-next tree got a conflict in
> > include/net/xfrm.h between commit d511337a1eda ("xfrm.h: Remove extern
> > from function prototypes") from the net-next tree and commit aba8269588=
30
> > ("{ipv4,xfrm}: Introduce xfrm_tunnel_notifier for xfrm tunnel mode
> > callback") from the ipsec-next tree.
>=20
> Thanks for the information, I'll do a rebase of the ipsec-next
> tree tomorrow.

Did you miss the end of the next paragraph:  "no action is required"?
Dave can fix this up (like I did) when he merges your tree into his.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__25_Sep_2013_09_59_19_+1000__nzaazIW/4Ty6+L+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.21 (GNU/Linux)

iQIcBAEBCAAGBQJSQidbAAoJEECxmPOUX5FEAwIP/RgTSWX4xAWn60xXfQd1+CXE
TjU81PxvOY5x0XdhBwTV0roBojZ9hFKyIvf4MfSRTnT2GJqLmMY9KGqFStow7ojf
NxGR/cTIZx32fkxPIIvJJdzpQvtz/egKugPst3XgA5dN6yD8J6tycs6xa1IlMrfo
FI7jvp244pw3DtNvoDYDU8qdRX+Y14PGcGoSjD/qVkyQX2p8T+X1xe0DFkqEu4CN
NX4JEkNaiHGfhSj7blpUvGbUgXg20ur7chl/pKz7/KPA6dmzTI64/CzAMAWdzXl5
o+j8pRhrjfp9+pLb9MaZ/v7vG//9BkdjzNjnm32yVSNj7tn2Kr7p4nrrqR6/2UVn
mcghspP8rlFcoQ/Wx0NXTWNa7PKLtuCQmJRHIChk7l8iXbo5dzHSCP3hf4Rqg1EI
qkAbfkc72ov1E/ejgdRn1cP6Q6QFcVt3/hZW8E3qF9lAfOYSKLpqGfYwasJH1e0B
psC0bVGYQIfOySQDO18dSkWYK5C6b8UfaWZqddABlErCIAXi1g8u7LgpkMq6QXzu
0dL5nlUrkZeb5lgClg6tKItRzrPAbIdL68bjUituhSD14VL5yFnlYjAYS4nr8fs4
yE6GJe9gaEYsphU7rt4GgQftHUVjJy2JoL/SW03Z+KWuTdD/jgR052i6P+FjFfN9
o+hRX/LUr4nBmy0aylEO
=IsD7
-----END PGP SIGNATURE-----

--Signature=_Wed__25_Sep_2013_09_59_19_+1000__nzaazIW/4Ty6+L+--
