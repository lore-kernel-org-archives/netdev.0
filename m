From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] 6lowpan: fix issues with byte ordering
 types
Date: Sun, 02 Mar 2014 19:21:08 -0500 (EST)
Message-ID: <20140302.192108.2054128492467762764.davem@davemloft.net>
References: <1393744175-23739-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589AbaCCAVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 19:21:11 -0500
In-Reply-To: <1393744175-23739-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Sun,  2 Mar 2014 08:09:32 +0100

> I got some mail from a "kbuild test robot" and it detected some byte
> ordering issues with the tag and datagram size value of 6LoWPAN IEEE
> 802.15.4 fragmentation header.
> 
> This patch series should fix the issues with the byte ordering.

Series applied, thank you.
