From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bcm63xx_enet: fix compilation failure after
 get_stats_count removal
Date: Tue, 15 Dec 2009 21:13:23 -0800 (PST)
Message-ID: <20091215.211323.104043001.davem@davemloft.net>
References: <200912151745.06131.ffainelli@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, mbizon@freebox.fr
To: ffainelli@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39267
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751977AbZLPFNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 00:13:22 -0500
In-Reply-To: <200912151745.06131.ffainelli@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <ffainelli@freebox.fr>
Date: Tue, 15 Dec 2009 17:45:06 +0100

> Subject: [PATCH] bcm63xx_enet: fix compilation failure after get_stats_count removal
> 
> This patch converts bcm63xx_enet to uset get_sset_count
> like the other drivers do.
> 
> Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>

Applied, and queued up for -stable, thanks.
