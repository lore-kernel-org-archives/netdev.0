From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net-next 0/3] Ethtool support for phy stats
Date: Thu, 31 Dec 2015 00:53:30 -0500 (EST)
Message-ID: <20151231.005330.2167119813455840522.davem@davemloft.net>
References: <1451489307-17048-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41944 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbbLaFxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 00:53:34 -0500
In-Reply-To: <1451489307-17048-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 30 Dec 2015 16:28:24 +0100

> This patchset add ethtool support for reading statistics from the PHY.
> The Marvell and Micrel Phys are then extended to report receiver
> packet errors and idle errors.
> 
> v2:
>   Fix linking when phylib is not enabled.
> v3:
>   Inline helpers into ethtool.c, so fixing when phylib is a module.
> v4:
>   Add missing static

Series applied, thanks Andrew.
