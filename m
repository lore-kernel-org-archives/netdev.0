From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: compiling issue, need a dummy
 function sk_diag_put_rings_cfg when CONFIG_NETLINK_MMAP disabled
Date: Wed, 24 Apr 2013 04:11:53 -0400 (EDT)
Message-ID: <20130424.041153.1240956751124977482.davem@davemloft.net>
References: <51779347.2000808@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, xemul@parallels.com, avagin@openvz.org,
	netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35020 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756156Ab3DXIL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 04:11:57 -0400
In-Reply-To: <51779347.2000808@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

aFrom: Chen Gang <gang.chen@asianux.com>
Date: Wed, 24 Apr 2013 16:09:43 +0800

> 
> When disable CONFIG_NETLINK_MMAP, need a dummy function for 
> sk_diag_put_rings_cfg, or will cause compiling issue.
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

This was fixed more than 12 hours ago.
