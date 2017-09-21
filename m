From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next ] net: Remove useless function
 skb_header_release
Date: Thu, 21 Sep 2017 15:25:45 -0700 (PDT)
Message-ID: <20170921.152545.51158481085588550.davem@davemloft.net>
References: <1505968771-92232-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60246 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUWZq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 18:25:46 -0400
In-Reply-To: <1505968771-92232-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@vip.163.com
Date: Thu, 21 Sep 2017 12:39:31 +0800

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> There is no one which would invokes the function skb_header_release.
> So just remove it now.
> 
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

As Joe Perches mentioned, there are comment references remaining.

This should be removed too because they can be confusing for people.

Thanks.
