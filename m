From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [PATCH 0/0]: Cassini bug fixes.
Date: Fri, 04 Jan 2008 10:16:15 +0100
Message-ID: <1199438175.13300.4.camel@bzorp.balabit>
References: <20080104.003231.127196736.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, panther@balabit.hu, hidden@sch.bme.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:40092 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753989AbYADJQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2008 04:16:18 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id C0CD8C137A
	for <netdev@vger.kernel.org>; Fri,  4 Jan 2008 10:16:16 +0100 (CET)
In-Reply-To: <20080104.003231.127196736.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-01-04 at 00:32 -0800, David Miller wrote:
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

Thank you very much. I'll see to test these patches on real hardware, a
minor problem is that we already returned the cards. I'm trying to get
them back.

-- 
Bazsi

