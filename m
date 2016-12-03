From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/5] use reset to set headers
Date: Sat, 03 Dec 2016 15:49:24 -0500 (EST)
Message-ID: <20161203.154924.8325343083937513.davem@davemloft.net>
References: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37134 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbcLCUt0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 15:49:26 -0500
In-Reply-To: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Fri,  2 Dec 2016 09:51:02 +0800

> This patch serial replace 'set' function to 'reset', since the
> offset is zero.  It's not necessary to use set, reset function is
> straightforward, and will remove the unnecessary add operation in
> set function.

Series applied, thanks.
