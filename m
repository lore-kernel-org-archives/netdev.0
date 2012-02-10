From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Fri, 10 Feb 2012 08:07:50 +0100
Message-ID: <1328857670.2436.11.camel@edumazet-laptop>
References: <1328253972.2480.42.camel@edumazet-laptop>
		<4F2B963F.4020504@profihost.ag>
		<20120208.202651.97221367956126026.davem@davemloft.net>
	 <20120209.171320.1013450846926790034.davem@davemloft.net>
	 <4F34C17D.6070805@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org,
	jwboyer@gmail.com, hch@infradead.org, netdev@vger.kernel.org,
	david@fromorbit.com, stable@vger.kernel.org
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:47140 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753713Ab2BJHHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 02:07:54 -0500
In-Reply-To: <4F34C17D.6070805@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 f=C3=A9vrier 2012 =C3=A0 08:04 +0100, Stefan Priebe - Pr=
ofihost AG
a =C3=A9crit :
> Hi,
>=20
> Am 09.02.2012 23:13, schrieb David Miller:
> > From: David Miller <davem@davemloft.net>
> > Date: Wed, 08 Feb 2012 20:26:51 -0500 (EST)
> >=20
> >> I'll work on coming up with something much more sensible tonight.
> >=20
> > Ok, here's what I'm testing right now, please review and test.
>=20
> thanks for doing this work! I can't test asap as i can't do udpates j=
ust
> for fun. I had the "luck" that last time there was the security bug
> recarding /proc/mem so i was  able to schedule it pretty fast.
>=20
> At least the patch applies fine ;-)
>=20

I'll do some build/run tests today, please Greg wait a bit before
applying this combo patch.

Thanks !
