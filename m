From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ip6_tunnel: fix setting hop_limit value for ipv6
 tunnel
Date: Fri, 08 Sep 2017 20:48:06 -0700 (PDT)
Message-ID: <20170908.204806.1057459442535263482.davem@davemloft.net>
References: <1504764515-13536-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
        <1504764515-13536-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42774 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753201AbdIIDsH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 23:48:07 -0400
In-Reply-To: <1504764515-13536-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Thu,  7 Sep 2017 14:08:35 +0800

> Similar to vxlan/geneve tunnel, if hop_limit is zero, it should fall
> back to ip6_dst_hoplimt().
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.
