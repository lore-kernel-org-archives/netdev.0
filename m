From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 0/2] Fixes for davinci MDIO on suspend/resume
Date: Thu, 13 Jun 2013 02:57:26 -0700 (PDT)
Message-ID: <20130613.025726.1446425087774615811.davem@davemloft.net>
References: <1370944925-11374-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38717 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758552Ab3FMJ51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:57:27 -0400
In-Reply-To: <1370944925-11374-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 11 Jun 2013 15:32:03 +0530

> This patch series fixes the following issues with Davinci MDIO
> * Bring up MDIO driver earlier than Ethernet driver so that ethernet driver
>   can communicate with the phy as soon as it is resumed.
> * On suspend/resume cycle the MDIO divider will be set to reset value so
>   this has to be programmed after resume.

Series applied, thanks.
