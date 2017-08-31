From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wl1251: add a missing spin_lock_init()
Date: Thu, 31 Aug 2017 13:10:54 -0700 (PDT)
Message-ID: <20170831.131054.158893500190039661.davem@davemloft.net>
References: <20170831185718.GA31245@amd>
        <20170831.122645.872320547726000124.davem@davemloft.net>
        <20170831195933.GA2788@amd>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvalo@codeaurora.org, torvalds@linux-foundation.org,
        xiyou.wangcong@gmail.com, akpm@linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: pavel@ucw.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57316 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751395AbdHaUK5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 16:10:57 -0400
In-Reply-To: <20170831195933.GA2788@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Machek <pavel@ucw.cz>
Date: Thu, 31 Aug 2017 21:59:33 +0200

> Do you plan to send another pull request to Linus, and can you take
> the patch, please?

Yes and yes.
