From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] dsa: bug fixes
Date: Mon, 21 Jan 2013 15:41:18 -0500 (EST)
Message-ID: <20130121.154118.1694545945517603251.davem@davemloft.net>
References: <1358798331-13055-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, buytenh@wantstofly.org,
	konszert@marvell.com
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811Ab3AUUlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 15:41:21 -0500
In-Reply-To: <1358798331-13055-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Mon, 21 Jan 2013 20:58:49 +0100

> These two patches are non-critical bugfixes based on net-next which I
> stumbled upon while working on Device Tree bindings for DSA (will comme
> as a separate patch later).
> 
> Florian Fainelli (2):
>   dsa: use an unique and non conflicting bus name for the slave MII bus
>   dsa: make dsa_switch_setup check for valid port names

This looks fine to me, all applied to net-next, thanks.
