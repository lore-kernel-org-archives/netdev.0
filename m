From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] net: ethernet: nb8800: support fixed-link DT node
Date: Wed, 24 Feb 2016 11:32:42 -0500 (EST)
Message-ID: <20160224.113242.2275582457531914447.davem@davemloft.net>
References: <56CB000A.1070809@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sf84@laposte.net, mans@mansr.com, netdev@vger.kernel.org
To: slash.tmp@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54282 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbcBXQcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 11:32:46 -0500
In-Reply-To: <56CB000A.1070809@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mason <slash.tmp@free.fr>
Date: Mon, 22 Feb 2016 13:33:14 +0100

> From: Sebastian Frias <sf84@laposte.net>
> 
> Under some circumstances, e.g. when connecting to a switch, the ethernet
> port will not be connected to a PHY. In that case a "fixed-link" DT node
> can be used to replace it.
> 
> https://stackoverflow.com/questions/31046172/device-tree-for-phy-less-connection-to-a-dsa-switch
> 
> This patch adds support for the "fixed-link" node to the nb8800 driver.
> 
> Signed-off-by: Sebastian Frias <sf84@laposte.net>
> Acked-by: Mans Rullgard <mans@mansr.com>

Applied, thanks.
