From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy/micrel: add ability to support 50MHz RMII clock on
 KZS8051RNL
Date: Mon, 14 Feb 2011 17:38:43 -0800 (PST)
Message-ID: <20110214.173843.59688745.davem@davemloft.net>
References: <e426eef4b15c4e1c77981094c3c8020012aaca42.1297685030.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.choi@micrel.com
To: baruch@tkos.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40441
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751420Ab1BOBiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 20:38:07 -0500
In-Reply-To: <e426eef4b15c4e1c77981094c3c8020012aaca42.1297685030.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baruch Siach <baruch@tkos.co.il>
Date: Mon, 14 Feb 2011 14:05:33 +0200

> Platform code can now set the MICREL_PHY_50MHZ_CLK bit of dev_flags in a fixup
> routine (registered with phy_register_fixup_for_uid()), to make the KZS8051RNL
> PHY work with 50MHz RMII reference clock.
> 
> Cc: David J. Choi <david.choi@micrel.com>
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Applied to net-next-2.6, thanks.
