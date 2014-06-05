From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv4: use skb frags api in udp4_hwcsum()
Date: Thu, 05 Jun 2014 00:52:07 -0700 (PDT)
Message-ID: <20140605.005207.1763681887596425544.davem@davemloft.net>
References: <1401750722-4324-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbaFEHwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 03:52:08 -0400
In-Reply-To: <1401750722-4324-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon,  2 Jun 2014 16:12:02 -0700

> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Also applied, thank you.
