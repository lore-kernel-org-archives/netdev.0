From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: tcp: tcp_v6_send_response() should give
 an owner to skb
Date: Thu, 29 Jan 2015 14:16:48 -0800 (PST)
Message-ID: <20150129.141648.1055363131409298519.davem@davemloft.net>
References: <1422453433.29618.58.camel@edumazet-glaptop2.roam.corp.google.com>
	<1422566339.21689.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbbA2WQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 17:16:49 -0500
In-Reply-To: <1422566339.21689.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Jan 2015 13:18:59 -0800

> On Wed, 2015-01-28 at 05:57 -0800, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> RST packets and ACK packets sent on behalf of TIME_WAIT sockets
>> do not have a socket owner currently.
> ...
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> ---
> 
> Please do not apply.

Ok.
