From: Gabor Juhos <juhosg@openwrt.org>
Subject: Re: Driver for embedded switch Micrel KS8995MA
Date: Tue, 13 Dec 2011 21:15:58 +0100
Message-ID: <4EE7B27E.7070803@openwrt.org>
References: <CAMVnO+n1g1rV_xLhqHONFcSBxJJ6wU3a8vzQ623jZKv0wYnh+A@mail.gmail.com> <CAMVnO+nbtJjyjKXVnQz__A+91cUb6P7VSpkd=f67L1G=rP-dag@mail.gmail.com> <4EE79B78.1040807@openwrt.org> <4EE7AC4B.2070606@openwrt.org> <CAMVnO+n38nMTYc7nRfbywidNRM_OYPW8nT1SNAKZyxmhCBb3AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
To: Frederic LAMBERT <frdrc66@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:41946 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753631Ab1LMUP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Dec 2011 15:15:59 -0500
In-Reply-To: <CAMVnO+n38nMTYc7nRfbywidNRM_OYPW8nT1SNAKZyxmhCBb3AA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011.12.13. 20:58 keltez=E9ssel, Frederic LAMBERT =EDrta:
> Wow, the list is safer than direct email !:-).=20

Yes, especially if you don't forget to reply to all recipients. ;)

> Thanks to Florian and you for the answer.
>=20
> Your driver helped me a lot because, due to an ambiguity of the
> datasheet, I could'nt understand why the switch wouldn't want to
> switch... until I add your driver in my kernel, and your xxx_start()
> write 0x0001 into reg#1!
>=20
> Anyway, I think the driver can help others as it did for me, so I wan=
t
> to submit it (with the small update on read() and write() functions).
>=20
> Is this list the best place to do that?

Yes, I think so.

-Gabor
