From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: atl1c issues on 3.8.2
Date: Fri, 22 Mar 2013 12:28:49 +0100
Message-ID: <20130322122849.72b3eccd@milhouse>
References: <20130312161753.281681f2@milhouse>
	<1363103144.13690.12.camel@edumazet-glaptop>
	<20130312180942.4198e88e@milhouse>
	<1363154258.13690.40.camel@edumazet-glaptop>
	<1363271460.29475.14.camel@edumazet-glaptop>
	<20130314231746.44a93e4d@milhouse>
	<1363302362.29475.42.camel@edumazet-glaptop>
	<20130315204457.21d46b89@milhouse>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/UKo8k3QtZ_1A5/BeGhcapJ/"; protocol="application/pgp-signature"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	"David S.Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>
To: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:39690 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754628Ab3CVL3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Mar 2013 07:29:06 -0400
In-Reply-To: <20130315204457.21d46b89@milhouse>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/UKo8k3QtZ_1A5/BeGhcapJ/
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, 15 Mar 2013 20:44:57 +0100
Michael B=C3=BCsch <m@bues.ch> wrote:

> I'm currently building a kernel with almost all debugging options
> turned on. I will test that tomorrow.

It took me a little bit longer than expected, but running the tests on
a kernel with almost all debugging options enabled shows no additional kern=
el messages. :/

--=20
Michael

--Sig_/UKo8k3QtZ_1A5/BeGhcapJ/
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRTEBxAAoJEPUyvh2QjYsOFD0QAKaf/MWvsEhhWzHDwsWZM5bf
igZqkhAsBZ41CWga7Zt/RnAY8mNb72e4EsbNjrDK7Bep+1ILBOkSyY3ebTkR0I1w
BTLWcnl12lwK/UCScxUMlYKsSsr2MyeqZlJJNMF2VNxsuHl7ZIgJEv1sji068GoW
qWmablkbUhz/1SM9/LTvYRMXKfQ3mZbIUU8pXLIU4ndpz6OCIvcRWddW+/nPvH+3
0TiE3T8US1lgI29cIzZBwsqG00DFLPxjWw4+BZjji3bcrs80RQ0HR3Ae+f23lvyi
cjnyiLkQN5EFU356jscjOmFDtKkgg8bUcmDfmkQqKdjMaESnnCfWyZ5k2em8PS1C
xAXQtasPBEBkd6xPNKiPPmKjm7JXQTDK+/ANRzq1Mh/JN20BykXlMViqqPyhfrSo
qxsrLliLr3JIB0ZvquVJYCTlVwVi9CHgt7Jm0P1RhS3GCuV+PKMiz8oEGxY6GI5H
2gkHwFhKbAGGyYWk5BGwwmFiCt8cwcDZtMVgoI3lMlMhccM8ObdkpEIbqk8O/bnC
21Vv9rsA57HE+4UILJ0FmPFdeJLvxZSkO3WH781LF61iZ+IK15IwS+V8hDotkmV/
YQZs4XFdB1SaHFoenUcyGdjwcyPvhLxLnqBipb4R4YmryNzgwbK3DEoMHkh9eMbn
OlpN/9O2d59kNrSFZUHm
=/GOP
-----END PGP SIGNATURE-----

--Sig_/UKo8k3QtZ_1A5/BeGhcapJ/--
