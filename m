From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 00/19] net: hns: Misc. HNS Bug Fixes & Code
 Improvements
Date: Thu, 30 Mar 2017 10:08:52 -0700 (PDT)
Message-ID: <20170330.100852.631078039848764955.davem@davemloft.net>
References: <20170330153106.14344-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: salil.mehta@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60396 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933524AbdC3RI4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 13:08:56 -0400
In-Reply-To: <20170330153106.14344-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salil Mehta <salil.mehta@huawei.com>
Date: Thu, 30 Mar 2017 16:30:47 +0100

> This patch set introduces various HNS bug fixes, optimizations and code
> improvements.

What tree are you targetting?

You say "net" in your Subject lines, but this series has cleanups and all sorts
of other things which are absolutely not appropriate for 'net' and are 'net-next'
material.
