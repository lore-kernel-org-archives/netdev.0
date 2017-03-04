From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] strparser: destroy workqueue on module exit
Date: Fri, 03 Mar 2017 20:44:22 -0800 (PST)
Message-ID: <20170303.204422.351679337231349580.davem@davemloft.net>
References: <1488572474-11779-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57160 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751560AbdCDEoX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 23:44:23 -0500
In-Reply-To: <1488572474-11779-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri,  3 Mar 2017 12:21:14 -0800

> Fixes: 43a0c6751a32 ("strparser: Stream parser for messages")
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
