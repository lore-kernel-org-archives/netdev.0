From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: remove one indentation level in
 tcp_rcv_state_process()
Date: Fri, 19 Apr 2013 14:22:53 -0400 (EDT)
Message-ID: <20130419.142253.2089468808729160282.davem@davemloft.net>
References: <1366341367.3205.85.camel@edumazet-glaptop>
	<1366391088.16391.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151Ab3DSSWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 14:22:55 -0400
In-Reply-To: <1366391088.16391.27.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Apr 2013 10:04:48 -0700

> On Thu, 2013-04-18 at 20:16 -0700, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> Remove one level of indentation 'introduced' in commit
>> c3ae62af8e75 (tcp: should drop incoming frames without ACK flag set)
>> 
>> @acceptable variable is a boolean.
>> 
>> This patch is a pure cleanup.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Yuchung Cheng <ycheng@google.com>
>> ---
> 
> Please drop this patch, I'll respin it later, when the "call
> tcp_replace_ts_recent() from tcp_ack()" issues are sorted out.

Done.
