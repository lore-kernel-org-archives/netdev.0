From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount of outgoing connections (unable to bind ... )
Date: Thu, 22 Apr 2010 00:08:02 +0400
Message-ID: <20100421200802.GA25130@ioremap.net>
References: <20100421003022.GA3107@ioremap.net> <1271828799.7895.1287.camel@edumazet-laptop> <20100421082559.GA32475@ioremap.net> <1271840535.7895.1612.camel@edumazet-laptop> <20100421095812.GA14778@ioremap.net> <1271849253.7895.1929.camel@edumazet-laptop> <20100421182723.GA17202@ioremap.net> <1271875416.7895.3033.camel@edumazet-laptop> <20100421185837.GB21249@ioremap.net> <1271877975.7895.3171.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.ru ([195.178.208.66]:46997 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754957Ab0DUUIG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 16:08:06 -0400
Content-Disposition: inline
In-Reply-To: <1271877975.7895.3171.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 09:26:15PM +0200, Eric Dumazet (eric.dumazet@gm=
ail.com) wrote:
> Le mercredi 21 avril 2010 =C3=A0 22:58 +0400, Evgeniy Polyakov a =C3=A9=
crit :
>=20
> > Damn it, I tried multiple times :)
> > You are right of course!
> >=20
>=20
> Here is a formal patch then :)

Ack. Thank you Eric!

--=20
	Evgeniy Polyakov
