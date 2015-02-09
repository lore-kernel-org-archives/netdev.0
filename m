From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next 0/3] bonding and mlx4 fixes for the HA/LAG
 support and mlx4 reset flow
Date: Mon, 09 Feb 2015 14:04:24 -0800 (PST)
Message-ID: <20150209.140424.1668257412724097646.davem@davemloft.net>
References: <1423388974-9635-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@kernel.org, amirv@mellanox.com,
	talal@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761386AbbBIWE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 17:04:27 -0500
In-Reply-To: <1423388974-9635-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  8 Feb 2015 11:49:31 +0200

> There are two fixes to the boding + mlx4 HA/LAG support from Moni
> and a patch from Yishai which does further hardening of the mlx4
> reset support for IB kernel ULPs.

Series applied, thanks.
