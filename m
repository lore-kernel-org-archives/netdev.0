From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: SIOCGMIIREG/SIOCSMIIREG: allow access to all
 mdio addresses
Date: Mon, 14 Mar 2011 15:02:23 -0700 (PDT)
Message-ID: <20110314.150223.242143322.davem@davemloft.net>
References: <1299775933-26981-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41875
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754101Ab1CNWBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:01:45 -0400
In-Reply-To: <1299775933-26981-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Korsgaard <jacmet@sunsite.dk>
Date: Thu, 10 Mar 2011 17:52:13 +0100

> phylib would silently ignore the phy_id argument to these ioctls and
> perform the read/write with the active phydev address, whereas most
> non-phylib drivers seem to allow access to all mdio addresses
> (E.G. pcnet_cs).
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

Applied, thanks.
