From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] phy: remove documentation of removed members of
 phy_device structure
Date: Sun, 13 Mar 2016 22:11:54 -0400 (EDT)
Message-ID: <20160313.221154.1708701708425728958.davem@davemloft.net>
References: <1457614738-17337-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172AbcCNCL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 22:11:57 -0400
In-Reply-To: <1457614738-17337-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Date: Thu, 10 Mar 2016 13:58:58 +0100

> Commit e5a03bfd873c ("phy: Add an mdio_device structure") removed addr,
> bus and dev member of the phy_device structure.
> This patch remove the documentation about those members.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>

Applied.
