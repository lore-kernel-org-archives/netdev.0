From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: report stop_queue and wake_queue
Date: Sun, 01 Oct 2017 04:11:21 +0100 (WEST)
Message-ID: <20171001.041121.494594494504682881.davem@davemloft.net>
References: <20170929183946.18364-1-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, haiyangz@microsoft.com,
        sthemmin@microsoft.com
To: sixiao@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34234 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750947AbdJADLX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 23:11:23 -0400
In-Reply-To: <20170929183946.18364-1-sixiao@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Xiao <sixiao@microsoft.com>
Date: Fri, 29 Sep 2017 11:39:46 -0700

> Report the numbers of events for stop_queue and wake_queue in
> ethtool stats.
> 
> Example:
> ethtool -S eth0
> NIC statistics:
> 	...
> 	stop_queue: 7
> 	wake_queue: 7
> 	...
> 
> Signed-off-by: Simon Xiao <sixiao@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied.
