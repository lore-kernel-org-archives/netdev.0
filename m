From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] bonding: slight optimization for
 bond_xmit_roundrobin()
Date: Mon, 22 Sep 2014 15:21:14 -0400 (EDT)
Message-ID: <20140922.152114.498793346386042050.davem@davemloft.net>
References: <541C29F9.6020001@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53141 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbaIVTVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 15:21:17 -0400
In-Reply-To: <541C29F9.6020001@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Fri, 19 Sep 2014 21:04:57 +0800

> When the slave is the curr_active_slave, no need to check
> whether the slave is active or not, it is always active.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied.
