From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 3/3] net/mlx4_core: Remove port type restrictions
Date: Fri, 03 Aug 2012 16:50:05 -0700 (PDT)
Message-ID: <20120803.165005.1461458771399653947.davem@davemloft.net>
References: <1343990318-10744-1-git-send-email-yevgenyp@mellanox.co.il>
	<1343990318-10744-4-git-send-email-yevgenyp@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41682 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025Ab2HCXuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 19:50:05 -0400
In-Reply-To: <1343990318-10744-4-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Fri,  3 Aug 2012 13:38:38 +0300

> Port1=Eth, Port2=IB restriction is no longer required.
> Having RoCE, there will always rdma port initialized over ConnectX
> physical port, no matter whether the link layer is IB or Ethernet.
> So we always have dual port IB device.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
