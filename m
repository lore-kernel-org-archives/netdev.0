From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next] l2tp: Refactor the codes with existing
 macros instead of literal number
Date: Tue, 23 Aug 2016 16:50:21 -0700 (PDT)
Message-ID: <20160823.165021.2014848184787521880.davem@davemloft.net>
References: <1471877402-31384-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, g.nault@alphalink.fr,
        philipp@redfish-solutions.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55841 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755147AbcHWXuZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 19:50:25 -0400
In-Reply-To: <1471877402-31384-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Mon, 22 Aug 2016 22:50:02 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> Use PPP_ALLSTATIONS, PPP_UI, and SEND_SHUTDOWN instead of 0xff,
> 0x03, and 2 separately.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
