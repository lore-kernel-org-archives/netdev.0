From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: make "ip -6 route get mark xyz" work.
Date: Fri, 16 May 2014 16:50:46 -0400 (EDT)
Message-ID: <20140516.165046.2258846078359656118.davem@davemloft.net>
References: <1400197121-16033-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49232 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207AbaEPUus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 16:50:48 -0400
In-Reply-To: <1400197121-16033-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Thu, 15 May 2014 16:38:41 -0700

> Currently, "ip -6 route get mark xyz" ignores the mark passed in
> by userspace. Make it honour the mark, just like IPv4 does.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied, thanks for fixing this.
