From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm:Use rcu_dereference_bh to deference pointer
 protected by rcu_read_lock_bh
Date: Thu, 16 Aug 2012 23:24:14 -0700 (PDT)
Message-ID: <20120816.232414.545877018277576779.davem@davemloft.net>
References: <1345184349-5849-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642Ab2HQGYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 02:24:17 -0400
In-Reply-To: <1345184349-5849-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I already applied your patch, as I told you here:

http://marc.info/?l=linux-netdev&m=134517122805719&w=2

This means you are submitting a patch which doesn't not even apply
to the net-next tree.

Instead of continuing to dig yourself deeper and deeper, take a
break, take a deep breath, and work slowly and carefully.
