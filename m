From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] tcp: remove one indentation level in
 tcp_rcv_state_process()
Date: Sat, 25 May 2013 23:23:00 -0700 (PDT)
Message-ID: <20130525.232300.1204753655676399515.davem@davemloft.net>
References: <1366341367.3205.85.camel@edumazet-glaptop>
	<1369324525.3301.384.camel@edumazet-glaptop>
	<1369443834.3301.464.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44595 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049Ab3EZGXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 02:23:01 -0400
In-Reply-To: <1369443834.3301.464.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 24 May 2013 18:03:54 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Remove one level of indentation 'introduced' in commit
> c3ae62af8e75 (tcp: should drop incoming frames without ACK flag set)
> 
> if (true) {
>         ...
> }
> 
> @acceptable variable is a boolean.
> 
> This patch is a pure cleanup.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
