From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] atheros/atlx: use SET_ETHTOOL_OPS directly
Date: Thu, 20 Mar 2014 16:07:01 -0400 (EDT)
Message-ID: <20140320.160701.546438379437520632.davem@davemloft.net>
References: <532965C3.6090706@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754341AbaCTUHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 16:07:04 -0400
In-Reply-To: <532965C3.6090706@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Wed, 19 Mar 2014 17:39:15 +0800

> As commit a6e28b34205b("staging/et131x: use SET_ETHTOOL_OPS
> directly"), using a wrapper around SET_ETHTOOL_OPS macro is
> not actually required, remove and use SET_ETHTOOL_OPS directly.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thank you.
