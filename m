From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: replace ip_fast_csum with csum_replace2
Date: Fri, 15 Mar 2013 09:12:49 -0400 (EDT)
Message-ID: <20130315.091249.1503473568232343958.davem@davemloft.net>
References: <1363337418-9609-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754806Ab3CONMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 09:12:32 -0400
In-Reply-To: <1363337418-9609-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 15 Mar 2013 16:50:18 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> replace ip_fast_csum with csum_replace2 to save cpu cycles
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
