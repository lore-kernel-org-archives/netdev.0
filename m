From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: Remove useless function
 skb_header_release
Date: Fri, 22 Sep 2017 20:41:21 -0700 (PDT)
Message-ID: <20170922.204121.1024494445343708417.davem@davemloft.net>
References: <1506047122-71116-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59292 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751832AbdIWDlV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 23:41:21 -0400
In-Reply-To: <1506047122-71116-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@vip.163.com
Date: Fri, 22 Sep 2017 10:25:22 +0800

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> There is no one which would invokes the function skb_header_release.
> So just remove it now.
> 
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

Applied, thanks.
