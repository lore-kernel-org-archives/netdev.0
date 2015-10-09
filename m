From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/5] Mellanox driver update to 4.3-rc4
Date: Fri, 09 Oct 2015 07:45:49 -0700 (PDT)
Message-ID: <20151009.074549.489131390877317168.davem@davemloft.net>
References: <1444307179-16105-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, achiad@mellanox.com, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754130AbbJIO36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 10:29:58 -0400
In-Reply-To: <1444307179-16105-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu,  8 Oct 2015 15:26:14 +0300

> Small set of fixes for net, which includes Carol's patches, a fix
> from Achiad to have the right behaviour for mlx5 Eth devices w.r.t 
> VLANs in promiscuous mode, a good-bye patch from Ido who left Mellanox
> and the 1st patch from Jiri to our NIC drivers (I love one-liners)...

Series applied except patch #2 which I applied already.

Thanks.
