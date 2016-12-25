From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Namespaceify tcp_tw_reuse knob
Date: Sat, 24 Dec 2016 21:07:28 -0500 (EST)
Message-ID: <20161224.210728.1213063344392674330.davem@davemloft.net>
References: <1482583387-79777-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50990 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750785AbcLYCHc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Dec 2016 21:07:32 -0500
In-Reply-To: <1482583387-79777-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Sat, 24 Dec 2016 20:43:07 +0800

> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

You need to provide something more than an empty commit message.

Instead, the commit message must explain why this particular
sysctl should be considered for namespacification and what
the implications, both good and bad, are for such a change.
