From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/10] net: use rcu for network scheduler API
Date: Tue, 10 Nov 2009 22:47:54 -0800 (PST)
Message-ID: <20091110.224754.27411831.davem@davemloft.net>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.339425269@vyatta.com>
	<4AF9AF09.60102@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40907
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753040AbZKKGr2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 01:47:28 -0500
In-Reply-To: <4AF9AF09.60102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Nov 2009 19:20:57 +0100

> Stephen Hemminger a =E9crit :
>> Use RCU to walk list of network devices in qdisc dump.
>> This could be optimized for large number of devices.
>>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
