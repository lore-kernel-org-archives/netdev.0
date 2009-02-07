From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] forcedeth: ethtool tx csum fix
Date: Sat, 07 Feb 2009 00:26:13 -0800 (PST)
Message-ID: <20090207.002613.244142929.davem@davemloft.net>
References: <498C8F1D.9070700@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, jgarzik@pobox.com, akpm@osdl.org,
	netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35976
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753521AbZBGI0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 03:26:17 -0500
In-Reply-To: <498C8F1D.9070700@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Fri, 06 Feb 2009 14:27:25 -0500

> This patch fixes the ethtool tx csum "set" command. A recent patch was
> submitted to remove HW_CSUM and use IP_CSUM instead. Therefore, the
> corresponding ethtool command should also be modified.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

Applied to net-next-2.6
