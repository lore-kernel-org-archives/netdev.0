From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/4] pxa168_eth: update call to phy_mii_ioctl()
Date: Tue, 24 Aug 2010 14:50:58 -0700 (PDT)
Message-ID: <20100824.145058.245415208.davem@davemloft.net>
References: <20100824165420.GJ29330@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ssanap@marvell.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53400
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755718Ab0HXVuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 17:50:40 -0400
In-Reply-To: <20100824165420.GJ29330@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Tue, 24 Aug 2010 18:54:20 +0200

> The phy_mii_ioctl() function changed recently.  It now takes a struct
> ifreq pointer directly.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
