From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Remove unused tw_cookie_values from
 tcp_timewait_sock
Date: Sun, 10 Mar 2013 17:09:48 -0400 (EDT)
Message-ID: <20130310.170948.743087268108414164.davem@davemloft.net>
References: <1362928719-13532-1-git-send-email-christoph.paasch@uclouvain.be>
	<1362931570.4051.34.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	william.allen.simpson@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53578 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299Ab3CJVJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 17:09:40 -0400
In-Reply-To: <1362931570.4051.34.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 10 Mar 2013 17:06:10 +0100

> On Sun, 2013-03-10 at 16:18 +0100, Christoph Paasch wrote:
>> tw_cookie_values is never used in the TCP-stack.
>> 
>> It was added by 435cf559f (TCPCT part 1d: define TCP cookie option,
>> extend existing struct's), but already at that time it was not used at
>> all, nor mentioned in the commit-message.
>> 
>> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
