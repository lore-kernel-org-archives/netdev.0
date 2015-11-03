From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 0/7] Mellanox mlx5e driver update, Nov 3
 2015
Date: Tue, 03 Nov 2015 10:42:14 -0500 (EST)
Message-ID: <20151103.104214.501477678704137737.davem@davemloft.net>
References: <1446530844-14077-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, saeedm@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755060AbbKCPmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 10:42:18 -0500
In-Reply-To: <1446530844-14077-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue,  3 Nov 2015 08:07:17 +0200

> This series contains bunch of small fixes to the mlx5e driver from Achiad.
 ...
> Changes from V0:
>   - removed the driver patch that dealt with IRQ affinity changes during
>     NAPI poll, as this is a generic problem which needs generic solution.

Series applied, thanks.
