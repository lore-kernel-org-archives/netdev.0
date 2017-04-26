From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: core: Prevent from dereferencing null pointer
 when releasing SKB
Date: Wed, 26 Apr 2017 14:47:40 -0400 (EDT)
Message-ID: <20170426.144740.554383033755326778.davem@davemloft.net>
References: <1493146695-5387-1-git-send-email-mhjungk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mhjungk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59376 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965357AbdDZSrm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:47:42 -0400
In-Reply-To: <1493146695-5387-1-git-send-email-mhjungk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Myungho Jung <mhjungk@gmail.com>
Date: Tue, 25 Apr 2017 11:58:15 -0700

> Added NULL check to make __dev_kfree_skb_irq consistent with kfree
> family of functions.
> 
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=195289
> 
> Signed-off-by: Myungho Jung <mhjungk@gmail.com>

Applied, thank you.
