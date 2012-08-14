From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: remove netdev_bonding_change()
Date: Tue, 14 Aug 2012 14:29:03 -0700 (PDT)
Message-ID: <20120814.142903.2258124984555555061.davem@davemloft.net>
References: <1344586497-2702-1-git-send-email-amwang@redhat.com>
	<1344586497-2702-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab2HNV3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:29:04 -0400
In-Reply-To: <1344586497-2702-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri, 10 Aug 2012 16:14:57 +0800

> I don't see any benifits to use netdev_bonding_change() than
> using call_netdevice_notifiers() directly.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied to net-next
