From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] forcedeth: replace init_timer_deferrable with
 setup_deferrable_timer
Date: Fri, 11 Aug 2017 14:27:26 -0700 (PDT)
Message-ID: <20170811.142726.1735307793150864194.davem@davemloft.net>
References: <1502352792-6930-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yanjun.zhu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60116 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753295AbdHKV11 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:27:27 -0400
In-Reply-To: <1502352792-6930-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@oracle.com>
Date: Thu, 10 Aug 2017 04:13:12 -0400

> Replace init_timer_deferrable with setup_deferrable_timer to simplify
> the source code.
> 
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>

Applied to net-next, thanks.
