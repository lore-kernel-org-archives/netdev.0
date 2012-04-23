From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: fix ethtool get settings
Date: Mon, 23 Apr 2012 17:24:13 -0400 (EDT)
Message-ID: <20120423.172413.581062619474068401.davem@davemloft.net>
References: <20120422045322.GA31559@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@emulex.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883Ab2DWVYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 17:24:18 -0400
In-Reply-To: <20120422045322.GA31559@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Sat, 21 Apr 2012 23:53:22 -0500

> ethtool get settings was not displaying all the settings correctly.
> use the get_phy_info to get more information about the PHY to fix this.
> 
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>

Applied, thanks.
