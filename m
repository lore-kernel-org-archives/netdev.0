From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/4] net: phy: at803x: Don't set gbit features for
 the AR8030 phy
Date: Sun, 17 Jan 2016 19:17:43 -0500 (EST)
Message-ID: <20160117.191743.972127939780068329.davem@davemloft.net>
References: <1452819324-4527-1-git-send-email-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, daniel@zonque.org,
	festevam@gmail.com, mans@mansr.com
To: martin.blumenstingl@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022AbcARARq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2016 19:17:46 -0500
In-Reply-To: <1452819324-4527-1-git-send-email-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Date: Fri, 15 Jan 2016 01:55:21 +0100

> The 8030 is only a "RMII Fast Ethernet PHY", thus it must not have the
> SUPPORTED_1000* bits set.
> 
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
> ---
> v2: refreshed patch

Series applied, but this is not the proper way to send a patch series.

A patch series describes a logically related group of changes, therefore
you must submit first a "[PATCH 0/N] ..." posting that clearly and fully
describes what the patch series is doing at a high level, and why.
