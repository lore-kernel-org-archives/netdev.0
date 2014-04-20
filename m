From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RESEND 2/2] net: phy: at803x: use
 genphy_config_init()
Date: Sun, 20 Apr 2014 18:19:16 -0400 (EDT)
Message-ID: <20140420.181916.2240621848017003976.davem@davemloft.net>
References: <1397661553-22117-1-git-send-email-zonque@gmail.com>
	<1397661553-22117-2-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, mugunthanvnm@ti.com,
	ujhelyi.m@gmail.com
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbaDTWTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2014 18:19:17 -0400
In-Reply-To: <1397661553-22117-2-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Wed, 16 Apr 2014 17:19:13 +0200

> Use the generic bits from genphy_config_init() instead of implementing
> the same functionality again.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>

Applied.
