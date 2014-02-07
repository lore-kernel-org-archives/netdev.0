From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: phy: sunxi: Add new compatibles
Date: Thu, 06 Feb 2014 19:47:23 -0800 (PST)
Message-ID: <20140206.194723.1272161937664295404.davem@davemloft.net>
References: <1391348953-10662-1-git-send-email-maxime.ripard@free-electrons.com>
	<1391348953-10662-2-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: maxime.ripard@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbaBGDrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 22:47:23 -0500
In-Reply-To: <1391348953-10662-2-git-send-email-maxime.ripard@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxime Ripard <maxime.ripard@free-electrons.com>
Date: Sun,  2 Feb 2014 14:49:12 +0100

> The Allwinner A10 compatibles were following a slightly different compatible
> patterns than the rest of the SoCs for historical reasons. Add compatibles
> matching the other pattern to the mdio driver for consistency, and keep the
> older one for backward compatibility.
> 
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Applied.
