From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac802154: Use pr_err(...) rather than printk(KERN_ERR
 ...)
Date: Wed, 30 Oct 2013 17:06:10 -0400 (EDT)
Message-ID: <20131030.170610.231481031187411692.davem@davemloft.net>
References: <1383118087-10128-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	dingtianhong@huawei.com
To: chenweilong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464Ab3J3VGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 17:06:12 -0400
In-Reply-To: <1383118087-10128-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Weilong <chenweilong@huawei.com>
Date: Wed, 30 Oct 2013 15:28:07 +0800

> This change is inspired by checkpatch.
> 
> Signed-off-by: Weilong Chen <chenweilong@huawei.com>

Applied to net-next, thanks.
