From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] l2tp: Refactor the codes with existing
 macros instead of literal number
Date: Sun, 21 Aug 2016 15:23:02 -0700 (PDT)
Message-ID: <20160821.152302.1471998923727708704.davem@davemloft.net>
References: <1471708347-18063-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, g.nault@alphalink.fr,
        philipp@redfish-solutions.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38943 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752602AbcHUWXD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2016 18:23:03 -0400
In-Reply-To: <1471708347-18063-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Sat, 20 Aug 2016 23:52:27 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> Use PPP_ALLSTATIONS, PPP_UI, and SEND_SHUTDOWN instead of 0xff,
> 0x03, and 2 separately.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
