From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next] net: Build IPv6 into kernel by default
Date: Fri, 10 Jul 2015 22:57:09 -0700 (PDT)
Message-ID: <20150710.225709.1099075922833429830.davem@davemloft.net>
References: <1436474549-491618-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbbGKGFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 02:05:30 -0400
In-Reply-To: <1436474549-491618-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 9 Jul 2015 13:42:29 -0700

> This patch makes the default to build IPv6 into the kernel. IPv6
> now has significant traction and any remaining vestiges of IPv6
> not being provided parity with IPv4 should be swept away. IPv6 is now
> core to the Internet and kernel.

I guess I'm fine with this, just fix up the doc error Dave Jones
pointed out.
