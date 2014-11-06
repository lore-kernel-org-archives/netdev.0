From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/fm10k: Avoid double setting of NETIF_F_SG
 for the HW encapsulation feature mask
Date: Thu, 06 Nov 2014 16:44:23 -0500 (EST)
Message-ID: <20141106.164423.844341922481879853.davem@davemloft.net>
References: <1415265664-10738-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59200 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbaKFVoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 16:44:24 -0500
In-Reply-To: <1415265664-10738-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu,  6 Nov 2014 11:21:04 +0200

> The networking core does it for the driver during registration time.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

I assume Jeff will pick this up and send it to me via his tree.
