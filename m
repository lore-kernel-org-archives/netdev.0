From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fs_enet: Add MPC5125 FEC support and PHY
 interface selection
Date: Mon, 19 Mar 2012 18:06:13 -0400 (EDT)
Message-ID: <20120319.180613.172802662010982591.davem@davemloft.net>
References: <1332025850-829-1-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com, vooon341@gmail.com
To: agust@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39788 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757010Ab2CSWIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 18:08:23 -0400
In-Reply-To: <1332025850-829-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anatolij Gustschin <agust@denx.de>
Date: Sun, 18 Mar 2012 00:10:50 +0100

> From: Vladimir Ermakov <vooon341@gmail.com>
> 
> Add compatible string for MPC5125 FEC. The FEC on MPC5125 additionally
> supports RMII PHY interface. Configure controller/PHY interface type
> according to the optional phy-connection-type property in the ethernet
> node. This property should be either "rmii" or "mii".
> 
> Signed-off-by: Vladimir Ermakov <vooon341@gmail.com>
> Signed-off-by: Anatolij Gustschin <agust@denx.de>

Applied.
