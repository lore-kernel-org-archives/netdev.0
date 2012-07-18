From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] jme: netpoll support
Date: Wed, 18 Jul 2012 09:45:24 -0700 (PDT)
Message-ID: <20120718.094524.264223189588300582.davem@davemloft.net>
References: <18143736.brt1iGhlQ1@al>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, netdev@vger.kernel.org
To: lekensteyn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755089Ab2GRQpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:45:24 -0400
In-Reply-To: <18143736.brt1iGhlQ1@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lekensteyn <lekensteyn@gmail.com>
Date: Tue, 17 Jul 2012 18:29:34 +0200

> From: Peter Wu <lekensteyn@gmail.com>
> 
> This patch adds the netpoll function to support netconsole. Tested and works
> fine on my "JMC250 PCI Express Gigabit Ethernet Controller" (PCI ID 0250).
> 
> Signed-off-by: Peter Wu <lekensteyn@gmail.com>

Applied to net-next

I really wonder if this driver works on SMP systems at all.
