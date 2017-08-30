From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Wed, 30 Aug 2017 10:11:43 -0700 (PDT)
Message-ID: <20170830.101143.2305098064824357647.davem@davemloft.net>
References: <20170815.175219.753462032002961032.davem@davemloft.net>
        <20170830094823.GA31503@amd>
        <87pobdt8qc.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pavel@ucw.cz, xiyou.wangcong@gmail.com,
        torvalds@linux-foundation.org, akpm@linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87pobdt8qc.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo@codeaurora.org>
Date: Wed, 30 Aug 2017 17:45:31 +0300

> Pavel Machek <pavel@ucw.cz> writes:
> 
>> Could we get this one in?
>>
>> wl1251 misses a spin_lock_init().
>>
>> https://www.mail-archive.com/netdev@vger.kernel.org/msg177031.html
>>
>> It seems pretty trivial, yet getting the backtraces is not nice.
> 
> It's in wireless-drivers-next and will be in 4.14-rc1:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git/commit/?id=6e9aae179f290f1a44fce7ef8e9a8e2dd68ed1e4

Is the bug only present in net-next?
