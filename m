From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2 1/2] netpoll: use ipv6_addr_equal() to
 compare ipv6 addr
Date: Mon, 28 Jan 2013 18:33:21 -0500 (EST)
Message-ID: <20130128.183321.509169387821058603.davem@davemloft.net>
References: <1359338121-10897-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab3A1XdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 18:33:23 -0500
In-Reply-To: <1359338121-10897-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 28 Jan 2013 09:55:20 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> ipv6_addr_equal() is faster.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
