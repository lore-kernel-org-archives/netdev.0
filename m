From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: ixp4xx_eth: use
 phy_ethtool_{get|set}_link_ksettings
Date: Mon, 04 Jul 2016 16:00:26 -0700 (PDT)
Message-ID: <20160704.160026.2200489369386254977.davem@davemloft.net>
References: <1467461175-25137-1-git-send-email-tremyfr@gmail.com>
	<1467461175-25137-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khalasa@piap.pl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [184.105.139.130] ([184.105.139.130]:50928 "EHLO
	shards.monkeyblade.net" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753729AbcGDXA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 19:00:27 -0400
In-Reply-To: <1467461175-25137-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat,  2 Jul 2016 14:06:15 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
