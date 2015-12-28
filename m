From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/3] Ethtool support for phy stats
Date: Mon, 28 Dec 2015 00:32:43 -0500 (EST)
Message-ID: <20151228.003243.762236700442924187.davem@davemloft.net>
References: <1451217508-22276-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834AbbL1Fcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 00:32:45 -0500
In-Reply-To: <1451217508-22276-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 27 Dec 2015 12:58:25 +0100

> This patchset add ethtool support for reading statistics from the PHY.
> The Marvell and Micrel Phys are then extended to report receiver
> packet errors and idle errors.
> 
> v2:
>   Fix linking when phylib is not enabled.

Series applied, thanks Andrew.
