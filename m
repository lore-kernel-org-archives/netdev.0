From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: dp83867: Fix device tree entries
Date: Mon, 08 Jun 2015 15:54:16 -0700 (PDT)
Message-ID: <20150608.155416.1662254927427107920.davem@davemloft.net>
References: <1433791855-8265-1-git-send-email-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: dmurphy@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932186AbbFHWyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 18:54:18 -0400
In-Reply-To: <1433791855-8265-1-git-send-email-dmurphy@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Murphy <dmurphy@ti.com>
Date: Mon, 8 Jun 2015 14:30:55 -0500

> Fix the device tree entries to modify the '_' to '-'.
> Also changes the names of the internal delay properties
> from -int- to -internal- as the -int- appeared as a keyword.
> 
> Signed-off-by: Dan Murphy <dmurphy@ti.com>
> ---
> 
> v1 - Fixed device tree entries and added data sheet reference per http://www.spinics.net/lists/netdev/msg331941.html

Applied to net-next, thanks.
