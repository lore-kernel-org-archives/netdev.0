From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Tue, 14 Aug 2012 00:37:32 -0700 (PDT)
Message-ID: <20120814.003732.714549073635415560.davem@davemloft.net>
References: <1344559958-29162-1-git-send-email-brutus@google.com>
	<20120814023155.ffe9c01d.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brutus@google.com, edumazet@google.com, netdev@vger.kernel.org
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56149 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754905Ab2HNHhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 03:37:34 -0400
In-Reply-To: <20120814023155.ffe9c01d.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Fink <billfink@mindspring.com>
Date: Tue, 14 Aug 2012 02:31:55 -0400

> I also believe it should be disabled by default, as that is
> the current behavior, and those who would gain an advantage
> from using it can easily enable it.

It benefits basically everyone, it makes things orders of
magnitude faster.

> While this could be a very useful feature in some environments,
> it seems to me it would be safest to have it disabled by default.

I violently disagree, and there is no way I'm having this
thing off by default.
