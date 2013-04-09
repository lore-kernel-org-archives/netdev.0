From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Tue, 09 Apr 2013 12:56:35 -0400 (EDT)
Message-ID: <20130409.125635.1837917915399498838.davem@davemloft.net>
References: <1365520026.3887.139.camel@edumazet-glaptop>
	<5235720.yJLYRg7eit@sifl>
	<1365521576.3887.147.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pmoore@redhat.com, casey@schaufler-ca.com, netdev@vger.kernel.org,
	mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36097 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763142Ab3DIQ4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 12:56:38 -0400
In-Reply-To: <1365521576.3887.147.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Apr 2013 08:32:56 -0700

> It looks like _I_ have to do your work. Sorry, I have no more time to
> spend on this topic. You'll have to convince David, not me.

I already have no interest in considering these changes seriously,
and I've already asked Paul multiple times to drop this idea.
