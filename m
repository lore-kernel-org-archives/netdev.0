From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: fix phy name example in documentation
Date: Wed, 19 Nov 2008 15:38:32 -0800 (PST)
Message-ID: <20081119.153832.171885701.davem@davemloft.net>
References: <20081117140313.8019.48296.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paulius.zaleckas@teltonika.lt
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46905
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751751AbYKSXic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 18:38:32 -0500
In-Reply-To: <20081117140313.8019.48296.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Date: Mon, 17 Nov 2008 16:03:13 +0200

> All MDIO bus drivers currently name bus with "%x" format.
> There is one exception where mv643xx_eth driver is using "%d".
> Phy address on the bus uses format "%02x".
> 
> Fixing phy name example to match all real life MDIO drivers.
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

Applied, thanks!
