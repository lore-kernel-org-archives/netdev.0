From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netem: add ECN capability
Date: Tue, 01 May 2012 13:17:50 -0400 (EDT)
Message-ID: <20120501.131750.636505003036346376.davem@davemloft.net>
References: <1335863465.11396.45.camel@edumazet-glaptop>
	<20120501.094051.655617860554790911.davem@davemloft.net>
	<20120501095938.7214e4a5@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	therbert@google.com, ncardwell@google.com, hagen@jauu.net
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51178 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755193Ab2EARR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 13:17:58 -0400
In-Reply-To: <20120501095938.7214e4a5@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 1 May 2012 09:59:38 -0700

> On Tue, 01 May 2012 09:40:51 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 01 May 2012 11:11:05 +0200
>> 
>> > From: Eric Dumazet <edumazet@google.com>
>> > 
>> > Add ECN (Explicit Congestion Notification) marking capability to netem
>> > 
>> > tc qdisc add dev eth0 root netem drop 0.5 ecn
>> > 
>> > Instead of dropping packets, try to ECN mark them.
>> > 
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> 
>> Applied.
> 
> At least give a day of review, rather than premature acceptance

Yeah, because Eric Dumazet is going to fall off the face of the
planet and not fix whatever problems you have with his work.

Get real Stephen.
