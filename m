From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: TX timestamps for IPv6 UDP packets
Date: Mon, 28 Feb 2011 12:31:01 -0800 (PST)
Message-ID: <20110228.123101.28812426.davem@davemloft.net>
References: <240353FF-7F9F-428C-84C3-3BD9B43213EE@halon.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, netdev@vger.kernel.org
To: anders@halon.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43210
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752955Ab1B1UaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 15:30:24 -0500
In-Reply-To: <240353FF-7F9F-428C-84C3-3BD9B43213EE@halon.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anders Berggren <anders@halon.se>
Date: Tue, 22 Feb 2011 22:43:47 +0100

> Enabling TX timestamps (SO_TIMESTAMPING) for IPv6 UDP packets, in 
> the same fashion as for IPv4. Necessary in order for NICs such as
> Intel 82580 to timestamp IPv6 packets.
> 
> Signed-off-by: Anders Berggren <anders@halon.se>

I'll apply this, thanks.
