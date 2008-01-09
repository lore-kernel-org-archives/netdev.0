From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCH 0/0]: Cassini bug fixes.
Date: Wed, 09 Jan 2008 17:13:07 +0100
Message-ID: <4784F293.9050707@balabit.hu>
References: <20080104.003231.127196736.davem@davemloft.net>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bazsi@balabit.hu, hidden@sch.bme.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:49556 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884AbYAIQNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 11:13:11 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 21A25C13F3
	for <netdev@vger.kernel.org>; Wed,  9 Jan 2008 17:13:09 +0100 (CET)
In-Reply-To: <20080104.003231.127196736.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Over the past day I've put together the following set of bug fixes for
> the Cassini driver.
> 
> At least with my setup it appears to basically work fine, not leak
> memory, and the SKB BUG messages go away too.
> 
> I'll be honest and say that I've devoted a couple days to this work,
> and therefore I have to turn my attention back to other tasks.  As a
> result, it means it will be some time before I can look seriously into
> any feedback folks provide.  And for that I apologize, but this
> already consumed too much of my time.
> 
> I'll be pushing these to Linus and -stable shortly.
> 
> Thanks.
> 

We tested the card, it works well, all previous bugs are gone (truesize 
bug messages and memory comsumption).

Thank you again.

--
Attila
