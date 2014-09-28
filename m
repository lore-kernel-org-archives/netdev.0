From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: check error pointer instead of NULL for
 ipv4_neigh_lookup()
Date: Sun, 28 Sep 2014 17:16:41 -0400 (EDT)
Message-ID: <20140928.171641.1050878454408330946.davem@davemloft.net>
References: <1411603673-19084-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47615 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591AbaI1VQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 17:16:43 -0400
In-Reply-To: <1411603673-19084-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 24 Sep 2014 17:07:53 -0700

> Fixes: commit f187bc6efb7250afee0e2009b6106 ("ipv4: No need to set generic neighbour pointer")
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thank you.
