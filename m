From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Thu, 26 Oct 2006 23:47:19 +0200
Message-ID: <1161899240.8884.30.camel@johannes.berg>
References: <C86180A8C204554D8A3323D8F6B0A29F018B5607@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-i1La7nOPqgj2GERCswaO"
Cc: Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org,
	Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>, Hong Liu <hong.liu@intel.com>,
	Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:40586 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1945945AbWJZVss
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 17:48:48 -0400
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F018B5607@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-i1La7nOPqgj2GERCswaO
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-10-26 at 14:41 -0700, Simon Barber wrote:
> Getting people to use wpa_supplicant almost exclusivly as the interface
> for wireless will improve a lot of things. One thing that might help
> here is to do some work on the wpa_cli - to make it easier for the
> startup scripts to do what they need, and also to make the command
> syntax easier for command line users to do what they need.

But we'll still want something to change channels when in monitor mode
etc, so it can't really be exclusive. Hence, we need another tool as
well.

johannes

--=-i1La7nOPqgj2GERCswaO
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARUEs5qVg1VMiehFYAQJ4iA//fzuv7MvEsZ6vng0TSKv7+k0TOxl+Qugb
SAnAmeKMgWqR4eEdLfQSwRHKQsRTJ2jtXLmRuPpIq9Ih8SDRWEW3eJ1unglLE6fE
f8LB9u61CBDNYWaG5VhmosTWvGDplT1Rpm8Dr3s9LYOXJaX9Y50M1Xh27hAWqQLB
MSC1tffByI24swd9ILyTG5GuA9cn40DNJGeFxj2sKMSbQsH2Bb3onKYicuo2itqG
SFQWCV9p0iq+AMiFDNFgPcUyh56TzabztuzJP1SGINSC1kOm//43Dr2fJFzqtXHn
Rr1TIWJ3SS1uyBo7YLFfBfjo0V38o9yUUnlFGQ0G7iwtXEp6pG9X0OZ3oXtRdWbv
Tg+fCKmTXzTsEPPOaS5cJ97m3agS2RGfgorEi0iAWr2JtFmsZL1Dv6q9cP94SftE
M05+KcZGUPEJgH0COS00Jjgm0CT/SUbCuhl1nagTxBO1Ai5Fq7HCSbdmSgOI7kZT
EodrKPbI4SzZErE1WhXrj1GFhKkYOZTYiCIR8SCoCymHpOhs6Jf+hqwQpFx4u2nq
i4vS/avdaMQW3O5ROoBmz/RhhV9FBqj0LGlQGQN7kG7wh3EBJO8V6e03cMQkGa49
+FRQcdzdUso7tblqDyuk9OzmPmoPcMn89jBa/het7QaFx46/1uBjpLi3517+P+b9
VKxGQaFICfg=
=HnpP
-----END PGP SIGNATURE-----

--=-i1La7nOPqgj2GERCswaO--

