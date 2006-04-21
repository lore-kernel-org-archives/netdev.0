From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 8/10] d80211: get rid of default management interface
Date: Fri, 21 Apr 2006 22:59:58 +0200
Message-ID: <1145653198.3897.47.camel@localhost>
References: <20060421205328.39BE2482C1@silver.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-UujNaCDuDRjAmTvjg8up"
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:15561 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750868AbWDUVAB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 17:00:01 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060421205328.39BE2482C1@silver.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-UujNaCDuDRjAmTvjg8up
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-04-21 at 22:53 +0200, Jiri Benc wrote:
> Default management interface (wlanXap) confuses users. It is only needed =
for
> AP mode (and only until interfaces are converted to use native 802.11
> frames).=20

What's the management interface used for? In some small discussion
didn't we say that we'd rather move to having one netlink socket for
this?
Maybe then we can get away with not having native 802.11 devices which
seem to somewhat scare people...

johannes

--=-UujNaCDuDRjAmTvjg8up
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARElHzKVg1VMiehFYAQKn8hAAgtYVh91JdwAr1CGTkuAponDlZWF1ZZbg
Dj4zcvkCZvpCJD6P6NwOyyLTRpkNMyQpza5hc4nfxV5z+cs9tmZzGy8JvDJX0Ax5
uIeleWTrhsUHzz71kBv7I3qwGxyG1WLEadx29aSqQaaA3UvVaTfEnFDr8pZNfCHS
HXgxuWRVLFt1OhEUViERs+AFvTQifvbNFevSEimTLQu+82n8rKyVciqDRSl4AcQa
Io0YK8JPIWqEn8ZYwp2zf4MH0NmZSV9KfJ/RtgIQcAYTYhXAmEXaRGuODTa48EuL
lvFETsyOn7PkS0zd+KKaiqSyxeChuewV102/l/xEmB+5ke3o+bvJs4LkNWw/lDW0
oszsbl5FK8fXwduo2+t0ABqwZWKo5HI3LjlOwoRgPoxFcpoWFt5YygmT7etHXmyi
i3V2gawWUqSZx5DYyxAzXJLdPgW0915SBN10GpKbU+YqWKNbg+ZEs7PLFWUzZ/HR
MiDwydqx0u7Pta5FvzdFizkC2xr5vB+BkTiN7QVkMWGiwB05BZe9iN/Tfmjy8TFO
sYjPhn4YltHjwCY586WUuyifLhfVvMgq/G8mcOUjzlDsKjbjtrgoGLzjuBUa5JFv
LRU712f84M3aZdvWBGwlrd++6eKBv/5zhHekSDdNJchmhhRfNTbA4RirW3OZ22Kj
Lew4XQ4s3Lk=
=DWbA
-----END PGP SIGNATURE-----

--=-UujNaCDuDRjAmTvjg8up--

