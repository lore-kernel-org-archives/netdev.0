From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/2] hv_netvsc: avoid unnecessary wakeups
 on subchannel creation
Date: Mon, 11 Sep 2017 14:21:57 -0700 (PDT)
Message-ID: <20170911.142157.2261457732253627669.davem@davemloft.net>
References: <20170906205306.10541-1-sthemmin@microsoft.com>
        <20170906205306.10541-3-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        devel@linuxdriverproject.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56096 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751151AbdIKVV5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 17:21:57 -0400
In-Reply-To: <20170906205306.10541-3-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed,  6 Sep 2017 13:53:06 -0700

> Only need to wakeup the initiator after all sub-channels
> are opened.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
