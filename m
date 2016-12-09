From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 00/22] Broadcom RoCE Driver (bnxt_re)
Date: Fri, 09 Dec 2016 10:26:02 -0500 (EST)
Message-ID: <20161209.102602.181161966975624956.davem@davemloft.net>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org
To: selvin.xavier@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58410 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753981AbcLIP0L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 10:26:11 -0500
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Selvin Xavier <selvin.xavier@broadcom.com>
Date: Thu,  8 Dec 2016 22:47:54 -0800

> This series introduces the RoCE driver for the Broadcom
> NetXtreme-E 10/25/40/50 gigabit RoCE HCAs. 
> This driver is dependent on the bnxt_en NIC driver and is 
> based on the bnxt_re branch in Doug's repository. bnxt_en changes
> required for this patch series is already available in this branch.
> 
> I am preparing a git repository with these changes as per Jason's
> comment and will share the details later today.

If this is targetted at the net-next tree, it is too late as I've
closed the net-next tree two nights ago.

Please resubmit this after the upcoming merge window closes.

Thanks.
