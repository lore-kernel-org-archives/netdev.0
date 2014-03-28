From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Implement vxlan ndo calls
Date: Fri, 28 Mar 2014 16:31:45 -0400 (EDT)
Message-ID: <20140328.163145.1341405434456644344.davem@davemloft.net>
References: <1395921724-2244-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40610 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbaC1Ubr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 16:31:47 -0400
In-Reply-To: <1395921724-2244-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 27 Mar 2014 14:02:01 +0200

> This short series adds support for the vxlan ndo calls, the udp
> port is programmed to the firmware using a new command we introduce
> here which is called "config device".

Series applied, thanks.
