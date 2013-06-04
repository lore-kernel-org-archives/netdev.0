From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 4/4] net: ipv6: Implement /proc/net/icmp6.
Date: Tue, 04 Jun 2013 12:57:05 -0700 (PDT)
Message-ID: <20130604.125705.546522804300318829.davem@davemloft.net>
References: <1370048750-28441-1-git-send-email-lorenzo@google.com>
	<1370048750-28441-4-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	yoshfuji@linux-ipv6.org, segoon@openwall.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab3FDT5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 15:57:06 -0400
In-Reply-To: <1370048750-28441-4-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Sat,  1 Jun 2013 10:05:50 +0900

> The format is based on /proc/net/icmp and /proc/net/{udp,raw}6.
> 
> Compiles and displays reasonable results with CONFIG_IPV6={n,m,y}
> Couldn't figure out how to test without CONFIG_PROC_FS enabled.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied.
