From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] 6lowpan: Fix endianness issue in
 is_addr_link_local().
Date: Sun, 10 Mar 2013 16:49:55 -0400 (EDT)
Message-ID: <20130310.164955.1948205970842271791.davem@davemloft.net>
References: <513B897D.2000207@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227Ab3CJUtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 16:49:46 -0400
In-Reply-To: <513B897D.2000207@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sun, 10 Mar 2013 04:11:57 +0900

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied and queued up for -stable, thanks.
