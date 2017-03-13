From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 1/1] net: Eliminate duplicated codes by
 creating one new function in_dev_select_addr
Date: Sun, 12 Mar 2017 23:27:23 -0700 (PDT)
Message-ID: <20170312.232723.1350664579927312912.davem@davemloft.net>
References: <1489120727-22775-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53626 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750752AbdCMG1Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:27:25 -0400
In-Reply-To: <1489120727-22775-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Fri, 10 Mar 2017 12:38:47 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> There are two duplicated loops codes which used to select right
> address in current codes. Now eliminate these codes by creating
> one new function in_dev_select_addr.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
