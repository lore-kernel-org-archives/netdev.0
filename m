From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/1] bnx2x: Add new 57840 device IDs
Date: Mon, 23 Jul 2012 00:58:28 -0700 (PDT)
Message-ID: <20120723.005828.149474925381777748.davem@davemloft.net>
References: <1343028343-15351-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389Ab2GWH62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 03:58:28 -0400
In-Reply-To: <1343028343-15351-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Mon, 23 Jul 2012 10:25:43 +0300

> The 57840 boards come in two flavours: 2 x 20G and 4 x 10G.
> To better differentiate between the two flavours, a separate device ID
> was assigned to each.
> The silicon default value is still the currently supported 57840 device ID
> (0x168d), and since a user can damage the nvram (e.g., 'ethtool -E')
> the driver will still support this device ID to allow the user to amend the
> nvram back into a supported configuration.
> 
> Notice this patch contains lines longer than 80 characters (strings).
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
