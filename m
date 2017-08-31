From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [GIT] Networking
Date: Thu, 31 Aug 2017 14:50:28 +0300
Message-ID: <87y3q0q7ln.fsf@kamboji.qca.qualcomm.com>
References: <87pobdt8qc.fsf@kamboji.qca.qualcomm.com>
        <20170830.101143.2305098064824357647.davem@davemloft.net>
        <87val5rmh8.fsf@kamboji.qca.qualcomm.com>
        <20170830.105447.125174575140677062.davem@davemloft.net>
        <87fuc8s5v9.fsf@kamboji.qca.qualcomm.com> <20170831065204.GA17812@amd>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
        torvalds@linux-foundation.org, akpm@linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831065204.GA17812@amd> (Pavel Machek's message of "Thu, 31
        Aug 2017 08:52:04 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Adding linux-wireless)

Pavel Machek <pavel@ucw.cz> writes:

> On Thu 2017-08-31 07:44:58, Kalle Valo wrote:
>> David Miller <davem@davemloft.net> writes:
>> 
>> > From: Kalle Valo <kvalo@codeaurora.org>
>> > Date: Wed, 30 Aug 2017 20:31:31 +0300
>> >
>> >> AFAICS the bug was introduced by 9df86e2e702c6 back in 2010. If the bug
>> >> has been there for 7 years so waiting for a few more weeks should not
>> >> hurt.
>> >
>> > As a maintainer you have a right to handle bug fixing in that way, but
>> > certainly that is not how I would handle this.
>> >
>> > It's easy to validate this fix, it's extremely unlikely to cause
>> > a regression, and fixes a problem someone actually was able to
>> > trigger.
>> >
>> > Deferring to -next only has the side effect of making people wait
>> > longer for the fix.
>> 
>> Yeah, you are right there. I did actually ponder which I tree should
>> commit it back in July but due to various reasons decided differently.
>
> Can we still get the fix to v4.13-final? :-).

I'm not planning to submit pull requests to 4.13 anymore. If you think
this is so important that it needs to be applied in the last minute (I
don't) you could always try to convince Dave to take it directly.

Or better yet, push it to the stable tree. If the merge window opens on
Sunday I suspect that the commit will be in Linus' tree sometime next
week. Then you can submit the request to the stable team to take it.

-- 
Kalle Valo
