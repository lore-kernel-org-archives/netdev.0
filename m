From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.14-stable] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Mon, 16 Jun 2014 20:03:48 -0700 (PDT)
Message-ID: <20140616.200348.1292584099498677236.davem@davemloft.net>
References: <1401607475-8367-1-git-send-email-weiyang@linux.vnet.ibm.com>
	<20140617024951.GB7886@richard>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhelgaas@google.com, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, ogerlitz@mellanox.com
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754617AbaFQDDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 23:03:50 -0400
In-Reply-To: <20140617024951.GB7886@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Tue, 17 Jun 2014 10:49:51 +0800

> I saw the fix for the crash during reboot is merged in mainline, while I am
> not sure how to check these backport is merged in the stable tree(not familiar
> to check it in stable tree.)
> 
> Do you suggest me to include that fix and send these backport again? Or?

I haven't gotten around to working with your backports, it's in my queue.
