From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: fec: avoid kernal crash by NULL
 pointer when no phy connection
Date: Tue, 09 Dec 2014 18:29:38 -0500 (EST)
Message-ID: <20141209.182938.256356809009914755.davem@davemloft.net>
References: <1418122016-32084-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de,
	bhutchings@solarflare.com, stephen@networkplumber.org
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789AbaLIX3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 18:29:40 -0500
In-Reply-To: <1418122016-32084-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Tue, 9 Dec 2014 18:46:56 +0800

> On i.MX6SX sabreauto board, when there have no phy daughter board connection,
> there have kernel crash by NULL pointer:
 ...
> Add phydev check to fix the issue.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied, thanks.
