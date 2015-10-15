From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: aquantia/teranetics: Convert to use
 module_phy_driver macro
Date: Wed, 14 Oct 2015 19:01:57 -0700 (PDT)
Message-ID: <20151014.190157.810018870760276601.davem@davemloft.net>
References: <1444818648.6933.1.camel@ingics.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, Shaohui.Xie@freescale.com,
	netdev@vger.kernel.org
To: axel.lin@ingics.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754821AbbJOBpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 21:45:51 -0400
In-Reply-To: <1444818648.6933.1.camel@ingics.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Axel Lin <axel.lin@ingics.com>
Date: Wed, 14 Oct 2015 18:30:48 +0800

> Use module_phy_driver macro to simplify the code a bit.
> 
> Signed-off-by: Axel Lin <axel.lin@ingics.com>

Applied to net-next, thanks.
