From: David Miller <davem@davemloft.net>
Subject: Re: [patch] usbnet: add timestamping support
Date: Thu, 29 Sep 2011 14:55:11 -0400 (EDT)
Message-ID: <20110929.145511.395326128419412056.davem@davemloft.net>
References: <1317305186-32700-1-git-send-email-michael@riesch.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oneukum@suse.de
To: michael@riesch.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756774Ab1I2SzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 14:55:25 -0400
In-Reply-To: <1317305186-32700-1-git-send-email-michael@riesch.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Riesch <michael@riesch.at>
Date: Thu, 29 Sep 2011 16:06:26 +0200

> In order to make USB-to-Ethernet-adapters (depending on usbnet) support
> timestamping, the "skb_defer_rx_timestamp" and "skb_tx_timestamp" function
> calls are added.
> 
> Signed-off-by: Michael Riesch <michael@riesch.at>

Applied.
