From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] datagram: Factor out sk queue referencing
Date: Tue, 21 Feb 2012 15:04:14 -0500 (EST)
Message-ID: <20120221.150414.1927921232746819822.davem@davemloft.net>
References: <4F43D49E.3010401@parallels.com>
	<4F43D4B9.8030005@parallels.com>
	<1329845959.18384.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755935Ab2BUUEU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 15:04:20 -0500
In-Reply-To: <1329845959.18384.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Feb 2012 18:39:19 +0100

> Le mardi 21 f=E9vrier 2012 =E0 21:30 +0400, Pavel Emelyanov a =E9crit=
 :
>> This makes lines shorter and simplifies further patching.
>>=20
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>>=20
>> ---
>>  net/core/datagram.c |    9 +++++----
>>  1 files changed, 5 insertions(+), 4 deletions(-)
>>=20
>> diff --git a/net/core/datagram.c b/net/core/datagram.c
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
