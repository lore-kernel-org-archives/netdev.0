From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnl: fix msg size calculation in if_nlmsg_size()
Date: Thu, 31 Mar 2016 16:50:45 -0400 (EDT)
Message-ID: <20160331.165045.1573907760635890245.davem@davemloft.net>
References: <1459440631-31729-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932260AbcCaUur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 16:50:47 -0400
In-Reply-To: <1459440631-31729-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 31 Mar 2016 18:10:31 +0200

> Size of the attribute IFLA_PHYS_PORT_NAME was missing.
> 
> Fixes: db24a9044ee1 ("net: add support for phys_port_name")
> CC: David Ahern <dsahern@gmail.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, and queued up for -stable, thanks Nicolas.

Man... this thing is getting really huge and unwieldly.
