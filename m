From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: Propagate lowerdev MTU changes
Date: Wed, 14 May 2014 15:37:34 -0400 (EDT)
Message-ID: <20140514.153734.430140821321742795.davem@davemloft.net>
References: <5371BE1F.7030508@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbaENThg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:37:36 -0400
In-Reply-To: <5371BE1F.7030508@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 13 May 2014 14:39:27 +0800

> When the physical MTU changes we should ensure that all existing MACVLAN
> dev MTU do not exceed the new lowerdev MTU. This patch adds that
> propagation.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied, thanks.
