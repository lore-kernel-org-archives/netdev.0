From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler
Date: Mon, 04 Apr 2011 11:10:39 -0700 (PDT)
Message-ID: <20110404.111039.135529829.davem@davemloft.net>
References: <20110404083058.2f2be9f1@nehalam>
	<1301934840.3142.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	fabio@gandalf.sssup.it, rizzo@iet.unipi.it
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54285
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754907Ab1DDSLQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:11:16 -0400
In-Reply-To: <1301934840.3142.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 04 Apr 2011 18:34:00 +0200

> Le lundi 04 avril 2011 =E0 08:30 -0700, Stephen Hemminger a =E9crit :
>> This is an implementation of the Quick Fair Queue scheduler develope=
d
>> by Fabio Checconi. The same algorithm is already implemented in ipfw
>> in FreeBSD. Fabio had an earlier version developed on Linux, I just
>> cleaned it up.  Thanks to Eric Dumazet for testing this under load.
>>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>=20
>> ---
>> v6.1 - add one more printk on error path
>=20
> Tested again this last version on net-next-2.6 and it seems fine.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
