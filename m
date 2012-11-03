From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: remove a useless NULL check
Date: Sat, 03 Nov 2012 14:52:15 -0400 (EDT)
Message-ID: <20121103.145215.437341115766557098.davem@davemloft.net>
References: <1351482233-10712-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385Ab2KCSwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 14:52:16 -0400
In-Reply-To: <1351482233-10712-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 29 Oct 2012 11:43:53 +0800

> In dev_forward_change(), it is useless to check if idev->dev
> is NULL, it is always non-NULL here.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
