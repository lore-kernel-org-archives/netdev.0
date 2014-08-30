From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH REPOST net 0/2] Setup mlx4 user space Ethernet QPs to
 properly handle VXLAN
Date: Fri, 29 Aug 2014 20:13:24 -0700 (PDT)
Message-ID: <20140829.201324.957134863530726203.davem@davemloft.net>
References: <1409147269-21472-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbaH3DNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 23:13:25 -0400
In-Reply-To: <1409147269-21472-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 27 Aug 2014 16:47:47 +0300

> This short series fixes the mlx4 driver setting of user space Ethernet QPs
> (e.g those opened by DPDK applications) such that they will properly handle
> VXLAN traffic/offloads

Series applied, thanks.
