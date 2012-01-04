From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net: phy: smsc: Move SMSC PHY constants to
 <linux/smscphy.h>
Date: Tue, 03 Jan 2012 20:24:26 -0500 (EST)
Message-ID: <20120103.202426.790719643234870291.davem@davemloft.net>
References: <1325633779-6159-1-git-send-email-javier@dowhile0.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, eballetbo@iseebcn.com,
	ben@decadent.org.uk, netdev@vger.kernel.org
To: javier@dowhile0.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754125Ab2ADBYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 20:24:35 -0500
In-Reply-To: <1325633779-6159-1-git-send-email-javier@dowhile0.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Javier Martinez Canillas <javier@dowhile0.org>
Date: Wed,  4 Jan 2012 00:36:18 +0100

> SMSC generation 4 LAN chips integrate an IEEE 802.3 ethernet physical layer.
> The ethernet driver for this family of devices needs to access the SMSC PHY
> registers and bit-fields.
> 
> So, this patch moves these constants to a place where it can be used for both
> the PHY and LAN drivers.
> 
> Signed-off-by: Javier Martinez Canillas <javier@dowhile0.org>

Applied.
