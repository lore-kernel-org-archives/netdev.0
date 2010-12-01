From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] sched: use xps information for qdisc NUMA
 affinity
Date: Wed, 01 Dec 2010 21:55:58 +0100
Message-ID: <1291236958.2856.1058.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
	 <1290705163.4274.12.camel@localhost>
	 <1291054477.3435.1302.camel@edumazet-laptop>
	 <20101201.124925.200368461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:49842 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755601Ab0LAU4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 15:56:05 -0500
Received: by wwb39 with SMTP id 39so218228wwb.1
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 12:56:04 -0800 (PST)
In-Reply-To: <20101201.124925.200368461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 12:49 -0800, David Miller a =C3=
=A9crit :

> I think this is good enough to cook in net-next-2.6
>=20
> Please use "net sched: " instead of just plain "sched: " in your
> commit header lines so that people don't confuse such changes
> with process scheduler ones :-)

Yes, I'll try to remember next time, thanks !


