From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: af_netlink module_put cleanup
Date: Tue, 02 Jan 2007 15:25:09 -0800 (PST)
Message-ID: <20070102.152509.48799363.davem@davemloft.net>
References: <200701021347.37952.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36737
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752326AbXABXZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 18:25:10 -0500
To: m.kozlowski@tuxland.pl
In-Reply-To: <200701021347.37952.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Date: Tue, 2 Jan 2007 13:47:37 +0100

> Hello,
> 
> 	This patch removes redundant argument check for module_put().
> 
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

Applied, thanks.
