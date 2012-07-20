From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: Return bool instead of int where
 appropriate
Date: Fri, 20 Jul 2012 11:00:29 -0700 (PDT)
Message-ID: <20120720.110029.1570711201616110891.davem@davemloft.net>
References: <1342769538-4039-1-git-send-email-subramanian.vijay@gmail.com>
	<1342771377.2626.6102.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026Ab2GTSAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:00:30 -0400
In-Reply-To: <1342771377.2626.6102.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Jul 2012 10:02:57 +0200

> On Fri, 2012-07-20 at 00:32 -0700, Vijay Subramanian wrote:
>> Applied to a set of static inline functions in tcp_input.c
>> 
>> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
>> ---
>>  net/ipv4/tcp_input.c |   16 ++++++++--------
>>  1 files changed, 8 insertions(+), 8 deletions(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
