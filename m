From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] mlx4 fixes for 4.1-rc2
Date: Tue, 05 May 2015 19:39:49 -0400 (EDT)
Message-ID: <20150505.193949.62860535292501915.davem@davemloft.net>
References: <1430834832-13559-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007AbbEEXjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:39:51 -0400
In-Reply-To: <1430834832-13559-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue,  5 May 2015 17:07:10 +0300

> Eran's fix is for a small off-by-one introduces on 4.1-rc1.
> 
> Yisahi fixes an issue with comes into play only on VMs with 
> many (> 256) vCPUs.

Series applied, thank you.
