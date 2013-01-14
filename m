From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ifb: dont hard code inet_net use
Date: Mon, 14 Jan 2013 15:13:44 -0500 (EST)
Message-ID: <20130114.151344.304668994986083700.davem@davemloft.net>
References: <50F2C860.1060602@mojatatu.com>
	<1358099194.8744.311.camel@edumazet-glaptop>
	<50F40489.70105@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bcrl@kvack.org, netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757741Ab3ANUNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 15:13:46 -0500
In-Reply-To: <50F40489.70105@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon, 14 Jan 2013 08:13:45 -0500

> On 13-01-13 12:46 PM, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> ifb should lookup devices in the appropriate namespace.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> 
>  Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Jamal, please don't put leading whitespace in your
signoffs and acks, the automated tools that look for
these tags in email threads looks for them to start in
the first column.

I've applied this patch, thanks.

Thanks.
