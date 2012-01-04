From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] r6040: cleanups
Date: Wed, 04 Jan 2012 15:56:58 -0500 (EST)
Message-ID: <20120104.155658.1700047535810385199.davem@davemloft.net>
References: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756913Ab2ADU5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 15:57:03 -0500
In-Reply-To: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed,  4 Jan 2012 19:59:32 +0100

> This series cleanups the r6040 driver by:
> - using appropriate definitions instead of bits values
> - fixing checkpatch errors and warnings
> 
> Florian Fainelli (6):
>   r6040: remove unused variables and definitions
>   r6040: define more MCR0 register bits
>   r6040: use MAC_RST bit definition with MCR1 read/writes
>   r6040: use definitions for MAC_SM register read/writes
>   r6040: use __aligned(size)
>   r6040: place comments before code

All applied, thanks Florian.
