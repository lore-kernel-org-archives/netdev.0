From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/3] Control ethernet PHY LEDs via LED subsystem
Date: Mon, 28 Mar 2016 18:10:27 +0200
Message-ID: <20160328161027.GC31462@lunn.ch>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
 <20160328084335.2b631e99@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vishal Thanki <vishalthanki@gmail.com>, f.fainelli@gmail.com,
	ujhelyi.m@gmail.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39837 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755071AbcC1QKa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 12:10:30 -0400
Content-Disposition: inline
In-Reply-To: <20160328084335.2b631e99@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen
 
> There already is LED control via ethtool.
> It is more important that the existing API (ethtool) still work.

I'm having trouble finding this. The man page for ethtool only
mentions -p --identify with respect to LEDs.

I also don't see anything in include/uapi/linux/ethtool.h

Please could you give more specific pointers.

Thanks
	Andrew
