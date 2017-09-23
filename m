From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] use setup_timer() helper function.
Date: Fri, 22 Sep 2017 18:22:31 -0700 (PDT)
Message-ID: <20170922.182231.828352137786459100.davem@davemloft.net>
References: <1506077902-1796-1-git-send-email-allen.lkml@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sameo@linux.intel.com
To: allen.lkml@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55070 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752109AbdIWBWc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 21:22:32 -0400
In-Reply-To: <1506077902-1796-1-git-send-email-allen.lkml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allen Pais <allen.lkml@gmail.com>
Date: Fri, 22 Sep 2017 16:28:17 +0530

> This series uses setup_timer() helper function. The series
> addresses the files under net/*.

There was a recent change to the nfc code in net-next which causes
your patches to not apply.

Please repsin against net-next, thanks.
