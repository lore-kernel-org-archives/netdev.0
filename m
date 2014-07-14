From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: Add ethtool support to show classifier
 filters added by the driver
Date: Mon, 14 Jul 2014 00:24:16 -0700 (PDT)
Message-ID: <20140714.002416.112385622071485557.davem@davemloft.net>
References: <alpine.LNX.2.03.1407121406100.1782@ws.cisco>
	<20140713.003145.1522390926593819876.davem@davemloft.net>
	<alpine.LNX.2.03.1407141150300.4699@ws.cisco>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202AbaGNHYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 03:24:19 -0400
In-Reply-To: <alpine.LNX.2.03.1407141150300.4699@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Mon, 14 Jul 2014 12:28:58 +0530 (IST)

> I am actually considering moving driver filter structures out of
> #ifdef CONFIG_RFS_ACCEL, and make it available always.

This is what I mean.
