From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] r6040: use an unique MDIO bus name
Date: Wed, 04 Jan 2012 15:56:48 -0500 (EST)
Message-ID: <20120104.155648.2173047085752942439.davem@davemloft.net>
References: <1325497800-21450-1-git-send-email-florian@openwrt.org>
	<1325703040-15680-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vova.kolpakov@gmail.com
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52736 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756825Ab2ADU4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 15:56:54 -0500
In-Reply-To: <1325703040-15680-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed,  4 Jan 2012 19:50:40 +0100

> We should use an unique MDIO bus name which does not clash with anything
> else in the system like the Fixed MDIO bus. The bus is now named:
> r6040-<card number> which is unique in the system.
> 
> Reported-by: Vladimir Kolpakov <vova.kolpakov@gmail.com>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
