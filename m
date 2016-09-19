From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/7] net: ILA resolver and generic resolver
 backend
Date: Sun, 18 Sep 2016 22:10:24 -0400 (EDT)
Message-ID: <20160918.221024.2210003128839126114.davem@davemloft.net>
References: <1473974361-2275254-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        roopa@cumulusnetworks.com, tgraf@suug.ch
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51720 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752443AbcISCK3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 22:10:29 -0400
In-Reply-To: <1473974361-2275254-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 15 Sep 2016 14:19:14 -0700

> This patch set implements an ILA host side resolver. This uses LWT
> to implement the hook to a userspace resolver and tracks pending
> unresolved address using the backend net resolver.

Can you please repost this series with Herbert Xu properly CC:'d
since he maintains rhashtable and is making changes to it recently
which might conflict with what you are proposing here?

Thanks.
