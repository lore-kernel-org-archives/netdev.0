From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12] bna: Update bna driver version to 3.0.2.1
Date: Thu, 15 Sep 2011 15:41:22 -0400 (EDT)
Message-ID: <20110915.154122.1981588096043602290.davem@davemloft.net>
References: <1314754068-31978-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934532Ab1IOTm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2011 15:42:29 -0400
In-Reply-To: <1314754068-31978-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 30 Aug 2011 18:27:36 -0700

>    This series is re-submitted with the comments addressed:
>    BNAD_PCI_UNMAP_SKB and BNAD_DIM_TIMER_STOP macros have been dropped
>    and added bnad_pci_unmap_skb API.
>    We are not adding new prefetch which we might selectively add later
>    for performance improvement.
>    This also addresses earlier comments.
> 
>    The following patch set contains TX and RX path changes and Ethtool
>    enhancements. This also fixes bugs found with v3.0.2.0 code. It cleans
>    up unused code, naming changes, formatting changes and comments
>    addition/deletion.
> 
>    This updates the Brocade BNA driver to v3.0.2.1.
> 
>    The driver has been compiled & tested against net-next-2.6(3.0.0-rc7)

Series applied, thanks.
