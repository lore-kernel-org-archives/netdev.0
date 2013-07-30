From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pktgen: Require CONFIG_INET due to use of
 IPv4 checksum function
Date: Tue, 30 Jul 2013 16:45:24 -0700 (PDT)
Message-ID: <20130730.164524.250005584108750137.davem@davemloft.net>
References: <ac3413a475e921b6ea915ecd1c610e6df07484f7.1375098208.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758511Ab3G3XpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 19:45:25 -0400
In-Reply-To: <ac3413a475e921b6ea915ecd1c610e6df07484f7.1375098208.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 29 Jul 2013 13:44:15 +0200

> Unlike for IPv6, the IPv4 checksum functions are only available
> if CONFIG_INET is set.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
