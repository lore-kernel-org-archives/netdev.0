From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/10] s390: use RCU to walk list of network devices
Date: Tue, 10 Nov 2009 22:49:04 -0800 (PST)
Message-ID: <20091110.224904.17187372.davem@davemloft.net>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.547660685@vyatta.com>
	<4AF9B3AA.6070104@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, netdev@vger.kernel.org,
	linux390@de.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40923
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752098AbZKKGsi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 01:48:38 -0500
In-Reply-To: <4AF9B3AA.6070104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Nov 2009 19:40:42 +0100

> Stephen Hemminger a =E9crit :
>> This is similar to other cases where for_each_netdev_rcu
>> can be used when gathering information.
>>=20
>> By inspection, don't have platform or cross-build environment
>> to validate.
>>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>=20
>>=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
