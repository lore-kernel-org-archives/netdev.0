From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] r8169: replace init_timer with setup_timer
Date: Sun, 12 Mar 2017 23:55:28 -0700 (PDT)
Message-ID: <20170312.235528.639830105862946615.davem@davemloft.net>
References: <1489309374-1979-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: yanjun.zhu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54596 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750726AbdCMGz3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:55:29 -0400
In-Reply-To: <1489309374-1979-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@oracle.com>
Date: Sun, 12 Mar 2017 05:02:54 -0400

> Replace init_timer with setup_timer to simplify the source code.
> 
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>

Applied.
