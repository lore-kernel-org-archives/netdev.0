From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: systemport: TX/NAPI improvements
Date: Fri, 24 Mar 2017 12:53:30 -0700 (PDT)
Message-ID: <20170324.125330.1257246130040337507.davem@davemloft.net>
References: <20170323173648.21143-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43672 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751832AbdCXTxb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 15:53:31 -0400
In-Reply-To: <20170323173648.21143-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 23 Mar 2017 10:36:45 -0700

> This patch series builds up on Doug's latest changes done in BCMGENET to reduce
> the number of spurious interrupts in NAPI, simplify pointer arithmetic and
> finally tracking of per TX ring statistics to be SMP friendly.

Series applied.
