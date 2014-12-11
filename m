From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net: fec: driver code clean and bug fix
Date: Wed, 10 Dec 2014 23:37:35 -0500 (EST)
Message-ID: <20141210.233735.1712517642146152188.davem@davemloft.net>
References: <1418260833-896-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	stephen@networkplumber.org
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbaLKEhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 23:37:38 -0500
In-Reply-To: <1418260833-896-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Thu, 11 Dec 2014 09:20:30 +0800

> The patch serial include code clean and bug fix:
> Patch#1: avoid dummy operation during suspend/resume test.
> Patch#2: bug fix for i.MX6SX SOC that clean all interrupt events during MAC initial process.
> Patch#3: before phy device link status is up, only enable MDIO bus interrupt.
> 
> V2:
> - Modify the comment form from David's suggestion.

Series applied, thanks.
