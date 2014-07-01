From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix some typos in comment
Date: Tue, 01 Jul 2014 14:21:00 -0700 (PDT)
Message-ID: <20140701.142100.1927219929078086115.davem@davemloft.net>
References: <1403769391-15222-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611AbaGAVVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 17:21:03 -0400
In-Reply-To: <1403769391-15222-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Thu, 26 Jun 2014 15:56:31 +0800

> In commit 371121057607e3127e19b3fa094330181b5b031e("net:
> QDISC_STATE_RUNNING dont need atomic bit ops") the
> __QDISC_STATE_RUNNING is renamed to __QDISC___STATE_RUNNING,
> but the old names existing in comment are not replaced with
> the new name completely.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks Ying.
