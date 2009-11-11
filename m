From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] netdev: add netdev_continue_rcu
Date: Tue, 10 Nov 2009 22:47:34 -0800 (PST)
Message-ID: <20091110.224734.186599311.davem@davemloft.net>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.200655064@vyatta.com>
	<4AF9AEAA.1080608@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40896
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752547AbZKKGrI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 01:47:08 -0500
In-Reply-To: <4AF9AEAA.1080608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Nov 2009 19:19:22 +0100

> Stephen Hemminger a =E9crit :
>> This adds an RCU macro for continuing search, useful for some
>> network devices like vlan.
>>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
