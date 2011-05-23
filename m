From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] snap: remove one synchronize_net()
Date: Mon, 23 May 2011 16:30:10 -0400 (EDT)
Message-ID: <20110523.163010.1058835332715388875.davem@davemloft.net>
References: <1306140108.2869.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933517Ab1EWUaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 16:30:15 -0400
In-Reply-To: <1306140108.2869.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 May 2011 10:41:48 +0200

> No need to wait for a rcu grace period after list insertion.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
