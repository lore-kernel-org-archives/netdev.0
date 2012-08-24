From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] w5300: using eth_hw_addr_random() for random
 MAC and set device flag
Date: Fri, 24 Aug 2012 13:31:01 -0400 (EDT)
Message-ID: <20120824.133101.13946222276796091.davem@davemloft.net>
References: <CAPgLHd-v=M6QrhT3YnTqUXWqyUa3TgVtNN3Cao1sPXd7stAEww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54595 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759945Ab2HXRbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 13:31:04 -0400
In-Reply-To: <CAPgLHd-v=M6QrhT3YnTqUXWqyUa3TgVtNN3Cao1sPXd7stAEww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 23 Aug 2012 15:28:40 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Using eth_hw_addr_random() to generate a random Ethernet address
> (MAC) to be used by a net device and set addr_assign_type.
> Not need to duplicating its implementation.
> 
> spatch with a semantic match is used to found this problem.
> (http://coccinelle.lip6.fr/)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
