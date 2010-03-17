From: David Miller <davem@davemloft.net>
Subject: Re: [Bridge] [PATCH] bridge: per-cpu packet statistics (v3)
Date: Tue, 16 Mar 2010 21:27:21 -0700 (PDT)
Message-ID: <20100316.212721.40843802.davem@davemloft.net>
References: <20100302095831.151c8bb5@nehalam>
	<1267553173.2839.9.camel@edumazet-laptop>
	<20100302153209.74742a96@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36005
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752792Ab0CQE07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 00:26:59 -0400
In-Reply-To: <20100302153209.74742a96@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 2 Mar 2010 15:32:09 -0800

> The shared packet statistics are a potential source of slow down
> on bridged traffic. Convert to per-cpu array, but only keep those
> statistics which change per-packet.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
