From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [GIT] Networking
Date: Thu, 31 Aug 2017 07:44:58 +0300
Message-ID: <87fuc8s5v9.fsf@kamboji.qca.qualcomm.com>
References: <87pobdt8qc.fsf@kamboji.qca.qualcomm.com>
        <20170830.101143.2305098064824357647.davem@davemloft.net>
        <87val5rmh8.fsf@kamboji.qca.qualcomm.com>
        <20170830.105447.125174575140677062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: pavel@ucw.cz, xiyou.wangcong@gmail.com,
        torvalds@linux-foundation.org, akpm@linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33288 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdHaEpG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 00:45:06 -0400
In-Reply-To: <20170830.105447.125174575140677062.davem@davemloft.net> (David
        Miller's message of "Wed, 30 Aug 2017 10:54:47 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Kalle Valo <kvalo@codeaurora.org>
> Date: Wed, 30 Aug 2017 20:31:31 +0300
>
>> AFAICS the bug was introduced by 9df86e2e702c6 back in 2010. If the bug
>> has been there for 7 years so waiting for a few more weeks should not
>> hurt.
>
> As a maintainer you have a right to handle bug fixing in that way, but
> certainly that is not how I would handle this.
>
> It's easy to validate this fix, it's extremely unlikely to cause
> a regression, and fixes a problem someone actually was able to
> trigger.
>
> Deferring to -next only has the side effect of making people wait
> longer for the fix.

Yeah, you are right there. I did actually ponder which I tree should
commit it back in July but due to various reasons decided differently.

-- 
Kalle Valo
