From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/phy: Remove return value for void function
Date: Wed, 23 Apr 2014 15:28:30 -0400 (EDT)
Message-ID: <20140423.152830.537994520929159512.davem@davemloft.net>
References: <1398194507-9387-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, joe@perches.com
To: Shruti@Freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757682AbaDWT2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 15:28:32 -0400
In-Reply-To: <1398194507-9387-1-git-send-email-Shruti@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shruti Kanetkar <Shruti@Freescale.com>
Date: Tue, 22 Apr 2014 14:21:47 -0500

> This was caught when using a spatch (aka. coccinelle) script
> written by Joe Perches.
> 
> Cc: Joe Perches <joe@perches.com>
> Signed-off-by: Shruti Kanetkar <Shruti@Freescale.com>

Applied to net-next, thanks.
