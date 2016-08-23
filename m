From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/5] net: ethernet: ti: cpsw: add cpdma multi-queue
 support
Date: Tue, 23 Aug 2016 00:14:10 -0700 (PDT)
Message-ID: <20160823.001410.1891719126833335234.davem@davemloft.net>
References: <1471889908-29983-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
        grygorii.strashko@ti.com, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, nsekhar@ti.com, dlide@ti.com
To: ivan.khoronzhuk@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48888 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752760AbcHWHQZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 03:16:25 -0400
In-Reply-To: <1471889908-29983-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Mon, 22 Aug 2016 21:18:23 +0300

> This series is intended to allow cpsw driver to use cpdma ability of
> h/w shaper to send/receive data with up to 8 tx and 8 rx queues. This
> series doesn't contain interface to configure h/w shaper itself, it
> contains only multi-queue support part and ability to configure number
> of tx/rx queues with ethtool, it also doesn't contain mapping of input
> traffic to rx queues, as it can depend on usage and requires separate
> interface for setup.

Series applied, thanks.
