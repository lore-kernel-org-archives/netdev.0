From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] qed: iWARP fixes and enhancements
Date: Tue, 26 Sep 2017 11:22:19 -0700 (PDT)
Message-ID: <20170926.112219.189095905256832710.davem@davemloft.net>
References: <1506244185-2129-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leon@kernel.org,
        linux-rdma@vger.kernel.org, dledford@redhat.com,
        Ariel.Elior@cavium.com
To: Michal.Kalderon@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33966 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966343AbdIZSWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 14:22:20 -0400
In-Reply-To: <1506244185-2129-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kalderon <Michal.Kalderon@cavium.com>
Date: Sun, 24 Sep 2017 12:09:41 +0300

> This patch series includes several fixes and enhancements
> related to iWARP.
> 
> Patch #1 is actually the last of the initial iWARP submission.
> It has been delayed until now as I wanted to make sure that qedr
> supports iWARP prior to enabling iWARP device detection.
> 
> iWARP changes in RDMA tree have been accepted and targeted at
> kernel 4.15, therefore, all iWARP fixes for this cycle are
> submitted to net-next.
> 
> Changes from v1->v2 
>   - Added "Fixes:" tag to commit message of patch #3
> 
> Signed-off by: Michal.Kalderon@cavium.com
> Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>

Series applied, thanks Michal.
