From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/5] Cache PMTU/redirects in inetpeer
Date: Thu, 10 Feb 2011 15:09:57 -0800 (PST)
Message-ID: <20110210.150957.115925131.davem@davemloft.net>
References: <20110209.221249.112596220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49331
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757171Ab1BJXJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 18:09:21 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6052224C088
	for <netdev@vger.kernel.org>; Thu, 10 Feb 2011 15:09:57 -0800 (PST)
In-Reply-To: <20110209.221249.112596220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 09 Feb 2011 22:12:49 -0800 (PST)

> This is what I've been working on for the past several days.

Just FYI I've pushed just the infrastructure bits (patches 1, 2,
and 3) into net-next-2.6 since those have no side effects.

I won't push the other two until I can do some good testing on
them.
