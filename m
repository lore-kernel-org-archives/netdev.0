From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: unify for_each_ip_tunnel_rcu()
Date: Wed, 14 Nov 2012 20:25:33 -0500 (EST)
Message-ID: <20121114.202533.2089087689873295761.davem@davemloft.net>
References: <1352706754-16594-1-git-send-email-amwang@redhat.com>
	<1352706754-16594-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992503Ab2KOBZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 20:25:34 -0500
In-Reply-To: <1352706754-16594-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 12 Nov 2012 15:52:34 +0800

> The defitions of for_each_ip_tunnel_rcu() are same,
> so unify it. Also, don't hide the parameter 't'.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
