From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 37/42] synclink: convert devices to new API (rev2)
Date: Mon, 12 Jan 2009 16:18:14 -0800 (PST)
Message-ID: <20090112.161814.241331603.davem@davemloft.net>
References: <20090107154835.37f4de4c@extreme>
	<20090107.180802.118061961.davem@davemloft.net>
	<m3y6xljtvi.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36740
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752674AbZAMASN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 19:18:13 -0500
In-Reply-To: <m3y6xljtvi.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Thu, 08 Jan 2009 23:49:37 +0100

>   git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git for-david
> 
> me:
>       WAN: Generic HDLC now uses IFF_WAN_HDLC private flag.
>       WAN: Allow hw HDLC drivers to override dev->get_stats.
>       Fix a comment in include/linux/netdevice.h.
>       WAN: Convert generic HDLC drivers to netdev_ops.
>       WAN: Fix NAPI interface in IXP4xx HSS driver.

Krzysztof, I integrated these changes into my local tree.
Thanks a lot.
