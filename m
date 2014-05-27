From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Tue, 27 May 2014 14:54:03 -0400 (EDT)
Message-ID: <20140527.145403.1114311769956769966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347AbaE0SyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 14:54:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If you want me to add this to -stable, you'll have to do the backporting
for me as this change doesn't come anywhere near to applying to v3.14.4

Thanks.
