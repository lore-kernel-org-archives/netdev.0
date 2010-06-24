From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6 4/4] vlan: 64 bit rx counters
Date: Thu, 24 Jun 2010 16:57:42 +0200
Message-ID: <4C237266.3050709@trash.net>
References: <1277376906.2816.287.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35366 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755773Ab0FXO5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 10:57:44 -0400
In-Reply-To: <1277376906.2816.287.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Use u64_stats_sync infrastructure to implement 64bit rx stats.
>
> (tx stats are addressed later)

Acked-by: Patrick McHardy <kaber@trash.net>
