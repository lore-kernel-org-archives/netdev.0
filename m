From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 16083] New: swapper: Page allocation failure
Date: Sat, 05 Jun 2010 02:59:57 -0700 (PDT)
Message-ID: <20100605.025957.27790926.davem@davemloft.net>
References: <1275599603.2533.58.camel@edumazet-laptop>
	<20100603143915.f1b0ba2b.akpm@linux-foundation.org>
	<1275602282.2533.72.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59430
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932654Ab0FEJ7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 05:59:47 -0400
In-Reply-To: <1275602282.2533.72.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Jun 2010 23:58:02 +0200

> So in this particular case, the bugzilla report can point to a real
> problem in our stack.
> 
> Failed allocations had been silent, we probably would never have
> noticed.

Agreed.

We'd be instead scratching our heads over reports about IGMP/MLD
reports not going out.
