From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] skge: add byte queue limit support
Date: Mon, 23 Jan 2012 14:25:32 -0500 (EST)
Message-ID: <20120123.142532.1845110856514231731.davem@davemloft.net>
References: <20120122.142501.1342631979051946828.davem@davemloft.net>
	<20120122114040.1b175e4c@nehalam.linuxnetplumber.net>
	<1327333702.2525.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923Ab2AWTZg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 14:25:36 -0500
In-Reply-To: <1327333702.2525.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Jan 2012 16:48:22 +0100

> Le dimanche 22 janvier 2012 =E0 11:40 -0800, Stephen Hemminger a =E9c=
rit :
>> This also changes the cleanup logic slightly to aggregate
>> completed notifications for multiple packets.
>>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> ---
>> v2 - change location of netdev_sent_queue to avoid race
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
