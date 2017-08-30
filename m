From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Wed, 30 Aug 2017 10:54:47 -0700 (PDT)
Message-ID: <20170830.105447.125174575140677062.davem@davemloft.net>
References: <87pobdt8qc.fsf@kamboji.qca.qualcomm.com>
        <20170830.101143.2305098064824357647.davem@davemloft.net>
        <87val5rmh8.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pavel@ucw.cz, xiyou.wangcong@gmail.com,
        torvalds@linux-foundation.org, akpm@linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87val5rmh8.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo@codeaurora.org>
Date: Wed, 30 Aug 2017 20:31:31 +0300

> AFAICS the bug was introduced by 9df86e2e702c6 back in 2010. If the bug
> has been there for 7 years so waiting for a few more weeks should not
> hurt.

As a maintainer you have a right to handle bug fixing in that way, but
certainly that is not how I would handle this.

It's easy to validate this fix, it's extremely unlikely to cause
a regression, and fixes a problem someone actually was able to
trigger.

Deferring to -next only has the side effect of making people wait
longer for the fix.
