From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] qed: Misc cleanups and fixes
Date: Thu, 06 Apr 2017 14:26:54 -0700 (PDT)
Message-ID: <20170406.142654.684792651795625089.davem@davemloft.net>
References: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39100 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751039AbdDFV04 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 17:26:56 -0400
In-Reply-To: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Thu, 6 Apr 2017 15:58:27 +0300

> Patches #1 and #2 revolve around register access performed by driver;
> The first merely adds some debug, while the second does some fixing
> of incorrect PTT usage as well as preventing issues similar to those
> fixed by 6f437d431930 ("qed: Don't use attention PTT for configuring BW").
> 
> Patch #3 better configures HW for architecture where cacheline isn't 64B.
> 
> Patches #4-#8 all affect iSCSI related functionaility - 
> adding statistics information [both to driver & management firmware],
> passing information on number of resources to qedi, and simplifying
> the Out-of-order implementation in SW.

Series applied, thanks Yuval.
