From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rds: remove the unneed NULL checking
Date: Fri, 09 May 2014 16:00:11 -0400 (EDT)
Message-ID: <20140509.160011.1892260902101470591.davem@davemloft.net>
References: <536B4801.9020802@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39274 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757088AbaEIUAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 16:00:13 -0400
In-Reply-To: <536B4801.9020802@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Thu, 8 May 2014 17:01:53 +0800

> unregister_net_sysctl_table will check the ctl_table_header,
> so remove the unneed checking
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thanks.
