From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/4] be2net: remove type argument of
 be_cmd_mac_addr_query()
Date: Sun, 30 Sep 2012 02:15:50 -0400 (EDT)
Message-ID: <20120930.021550.267728623171234838.davem@davemloft.net>
References: <1348843184-22214-1-git-send-email-sathya.perla@emulex.com>
	<29e503e4-1dc2-4430-8a25-b20f49c1b3f4@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54987 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698Ab2I3GPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2012 02:15:52 -0400
In-Reply-To: <29e503e4-1dc2-4430-8a25-b20f49c1b3f4@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 28 Sep 2012 20:09:41 +0530

> All invocations of this routine use the same type value.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
