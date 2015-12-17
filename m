From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] drivers: net: cpsw: Fix bugs in fixed-link PHY
 DT parsing
Date: Thu, 17 Dec 2015 15:45:08 -0500 (EST)
Message-ID: <20151217.154508.505711333985621252.davem@davemloft.net>
References: <20151209223115.6c5a400f.drivshin.allworx@gmail.com>
	<1741588.Ve76Z1ZI87@localhost>
	<cover.1450309613.git.drivshin@allworx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, systemprogrammierung.brunner@gmail.com,
	mugunthanvnm@ti.com, kernel@iktek.de, dtrautmann@ibhsoftec-sps.de
To: drivshin.allworx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139AbbLQUpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:45:10 -0500
In-Reply-To: <cover.1450309613.git.drivshin@allworx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Date: Wed, 16 Dec 2015 23:02:08 -0500

> I have tested on the following hardware configurations:
>  - (EVMSK) dual emac with two real MDIO-connected phys using RGMII-TXID
>  - single emac with fixed-link using RGMII
> Testing of other CPSW emac configurations that folks may have would
> be appreciated.

I'm going to wait until some others give some feedback and testing
results on this one, thanks.
