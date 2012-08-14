From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: move and rename netif_notify_peers()
Date: Tue, 14 Aug 2012 14:28:57 -0700 (PDT)
Message-ID: <20120814.142857.1470514951488168790.davem@davemloft.net>
References: <1344586497-2702-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ian.Campbell@citrix.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545Ab2HNV26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:28:58 -0400
In-Reply-To: <1344586497-2702-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri, 10 Aug 2012 16:14:56 +0800

> I believe net/core/dev.c is a better place for netif_notify_peers(),
> because other net event notify functions also stay in this file.
> 
> And rename it to netdev_notify_peers().
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Ian Campbell <Ian.Campbell@citrix.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied to net-next
