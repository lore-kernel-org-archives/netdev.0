From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: Update tx_errors statistics if vxlan_build_skb
 return err.
Date: Tue, 06 Sep 2016 13:42:20 -0700 (PDT)
Message-ID: <20160906.134220.1739546326140401345.davem@davemloft.net>
References: <1472986371-75583-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53672 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934248AbcIFUmV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 16:42:21 -0400
In-Reply-To: <1472986371-75583-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Sun,  4 Sep 2016 18:52:51 +0800

> If vxlan_build_skb return err < 0, tx_errors should be also increased.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied to net-next.
