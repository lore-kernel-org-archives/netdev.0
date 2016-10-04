From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/2][pull request] 100GbE Intel Wired LAN Driver
 Updates 2016-10-02
Date: Mon, 03 Oct 2016 23:29:02 -0400 (EDT)
Message-ID: <20161003.232902.336303351855675086.davem@davemloft.net>
References: <1475476843-23405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753501AbcJDD3J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 23:29:09 -0400
In-Reply-To: <1475476843-23405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun,  2 Oct 2016 23:40:41 -0700

> This series contains updates to fm10k only.
> 
> Jake fixes an issue where PTP applications requesting software timestamps
> may complain that the requested mode is not supported, so add a generic
> callback for those drivers that have software transmit timestamp support
> enabled.  Then provides a trivial cleanup where a code was not wrapped
> properly.  Got make sure that code looks good in a 80 character limit.
> 
> The following are changes since commit 7c70c4f8b2bf5ed777120f3d70efe35e64930c10:
>   cxgb4: unexport cxgb4_dcb_enabled
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Pulled.
