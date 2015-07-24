From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [patch net-next 0/4] Introduce Mellanox Technologies Switch
 ASICs switchdev drivers
Date: Fri, 24 Jul 2015 00:38:13 +0000
Message-ID: <C9CEEB0A-4CF7-4D82-B3E0-D2B3B5FC251E@intel.com>
References: <1437666216-3149-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bB-1LcnzvEegiHQ=6OKZ3tJVkTkyENFC1Th5XjSS4CMBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_A748D237-1DF3-48F7-96A0-137850445520";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Florian Fainelli" <f.fainelli@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	"ast@plumgrid.com" <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	John Linville <linville@tuxdriver.com>,
	"Andy Gospodarek" <andy@greyhouse.net>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44235 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752291AbbGXAiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 20:38:14 -0400
In-Reply-To: <CAE4R7bB-1LcnzvEegiHQ=6OKZ3tJVkTkyENFC1Th5XjSS4CMBw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_A748D237-1DF3-48F7-96A0-137850445520
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Jul 23, 2015, at 5:03 PM, Scott Feldman <sfeldma@gmail.com> wrote:
>=20
> On the CHECKs on space after cast, should we modify checkpatch.pl to
> not flag those for drivers/net?

Please don't. My internal parser really wants to see the cast right up =
against whatever it is casting. Has this practice been changing and I =
haven't noticed?

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_A748D237-1DF3-48F7-96A0-137850445520
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVsYj0AAoJEDwO/+eO4+5uM4gQAKaDT/dfipWJTXBqytLgp2Wo
wy872egTIBYb9N8fK6UN7Mrk9CMp9qClAUWSEwbtDHqEoXyx2bSy9IxP554i6KfE
LxrkRAyIBSkgQ7fq+dw984L8oaFFa2tYW2wXjFnFMS/HjERDaboED5K//Aq+O1hr
uo3SksTTotcCcy0nF1OdyYBSoglHU/HKUn+rNYb2LQS0Q1w0kDkufSkbtMRc8339
cAZRAL2UP2Ap6qWNORVNXbpPaWQgAgzOW5jZrq2do9mKDzfqJ0oLfzpNmumzgbTD
dbM564c6IkRIpwG3cCvFLXChXLX/uXkKbXVK9kLG94EbAVrVQM8zZFnpSqVNRluX
zz12ui8mZdf+Hza0WEd8ZaH7uyYhCzXtvXugSkpbr4N26k/eTej0YDkomdqDOyGJ
HHexFu5/xSE+gx1PLKAAl59NadTsoIrQb8wO2KFS2I4wVCbx3SA48ZoeB/a5gR+W
8vism4OESSuDeX5yvkwLFm/bL2vOJ7RCbETSDzRShApjvdzNzvGrtcfGq4YRMrTC
2QvNAxCwijoRN+4xF1guHihAhxs/bk6Zj/eoOwg5+MDixZghpuYDnGy00HChyXC0
WU0jVNDI6JEt0VOqUbFOxxWWJ417klohB392ysT2WJ9g6r66tRVl+3JCDnRrQfeH
aNFktQjg37Ev8DQUbVN6
=0jRI
-----END PGP SIGNATURE-----

--Apple-Mail=_A748D237-1DF3-48F7-96A0-137850445520--
