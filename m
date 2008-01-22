From: David Miller <davem@davemloft.net>
Subject: Re: [BNX2]: Fix driver software flag namespace.
Date: Mon, 21 Jan 2008 19:51:53 -0800 (PST)
Message-ID: <20080121.195153.71853212.davem@davemloft.net>
References: <20080121.171755.250146056.davem@davemloft.net>
	<1200970820.10010.58.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51593
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753443AbYAVDvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 22:51:47 -0500
In-Reply-To: <1200970820.10010.58.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 21 Jan 2008 19:00:20 -0800

> [BNX2]: Fix driver phy_flags name space.
> 
> Prefix "bp->phy_flags" names with BNX2_PHY_FLAG_* for consistency.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
