From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] netdevice.h: fix ndo_bridge_* comments
Date: Tue, 17 Mar 2015 14:58:53 -0400 (EDT)
Message-ID: <20150317.145853.1328983502307585172.davem@redhat.com>
References: <1426587360-5368-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	roopa@cumulusnetworks.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52079 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753224AbbCQS7B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2015 14:59:01 -0400
In-Reply-To: <1426587360-5368-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 17 Mar 2015 11:16:00 +0100

> The argument 'flags' was missing in ndo_bridge_setlink().
> ndo_bridge_dellink() was missing.
> 
> Fixes: 407af3299ef1 ("bridge: Add netlink interface to configure vlans on bridge ports")
> Fixes: add511b38266 ("bridge: add flags argument to ndo_bridge_setlink and ndo_bridge_dellink")
> CC: Vlad Yasevich <vyasevic@redhat.com>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
