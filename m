From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] fou: avoid missing unlock in failure path
Date: Tue, 14 Apr 2015 14:42:44 -0400 (EDT)
Message-ID: <20150414.144244.308177204962909192.davem@davemloft.net>
References: <1429029150-31710-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	dan.carpenter@oracle.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbbDNSmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 14:42:47 -0400
In-Reply-To: <1429029150-31710-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 14 Apr 2015 09:32:30 -0700

> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

This doesn't apply cleanly to the net-next tree, please resubmit and this will
give you a chance to add the Fixes: tag too.
