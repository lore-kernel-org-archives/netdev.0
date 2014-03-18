From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/i40e: Avoid double setting of NETIF_F_SG
 for the HW encapsulation feature mask
Date: Tue, 18 Mar 2014 13:27:00 -0400 (EDT)
Message-ID: <20140318.132700.571269685777987248.davem@davemloft.net>
References: <1395131805-14146-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757162AbaCRR1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 13:27:02 -0400
In-Reply-To: <1395131805-14146-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 18 Mar 2014 10:36:45 +0200

> The networking core does it for the driver during registration time.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied.
