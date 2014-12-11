From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 00/10] mlx4 driver update
Date: Thu, 11 Dec 2014 14:48:01 -0500 (EST)
Message-ID: <20141211.144801.848618516417939557.davem@davemloft.net>
References: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com,
	talal@mellanox.com, jackm@dev.mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758732AbaLKTsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 14:48:06 -0500
In-Reply-To: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 11 Dec 2014 10:57:50 +0200

> This series from Matan, Jenny, Dotan and myself is mostly about adding
> support to a new performance optimized flow steering mode (patches 4-10).
> 
> The 1st two patches are small fixes (one for VXLAN and one for SRIOV),
> and the third patch is a fix to avoid hard-lockup situation when many
> (hunderds) processes holding user-space QPs/CQs get events.
> 
> Matan and Or. 

Series applied, thanks.
