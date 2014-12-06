From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: Fix flow mask validation.
Date: Fri, 05 Dec 2014 21:42:56 -0800 (PST)
Message-ID: <20141205.214256.1822636831327776032.davem@davemloft.net>
References: <1417417457-1492-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbaLFFi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 00:38:27 -0500
In-Reply-To: <1417417457-1492-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Sun, 30 Nov 2014 23:04:17 -0800

> Following patch fixes typo in the flow validation. This prevented
> installation of ARP and IPv6 flows.
> 
> Fixes: 19e7a3df72 ("openvswitch: Fix NDP flow mask validation")
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied and queued up for -stable, thanks.
