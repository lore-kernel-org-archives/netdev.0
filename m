From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: remove unused function
 ipv6_inherit_linklocal()
Date: Mon, 05 May 2014 15:30:45 -0400 (EDT)
Message-ID: <20140505.153045.857124489317693183.davem@davemloft.net>
References: <1399076461-12172-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbaEETar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 15:30:47 -0400
In-Reply-To: <1399076461-12172-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri,  2 May 2014 17:21:01 -0700

> It is no longer used after commit e837735ec406a347756e
> (ip6_tunnel: ensure to always have a link local address).
> 
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
