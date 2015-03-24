From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] mlx4 driver RC fixes
Date: Tue, 24 Mar 2015 15:23:35 -0400 (EDT)
Message-ID: <20150324.152335.1568501485253135933.davem@davemloft.net>
References: <1427203119-27149-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, talal@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231AbbCXTXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 15:23:37 -0400
In-Reply-To: <1427203119-27149-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 24 Mar 2015 15:18:37 +0200

> Ido's patch should go to -stable of >= 3.14 too, the issue is older but it
> hits us with VXLAN for which driver support dates there.
> 
> As for Jack's fix, for the time being, picking it to 4.0 is OK.

Series applied and patch #1 queue up for -stable, thanks.
