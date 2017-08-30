From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [GIT] Networking
Date: Wed, 30 Aug 2017 17:45:31 +0300
Message-ID: <87pobdt8qc.fsf@kamboji.qca.qualcomm.com>
References: <20170815.175219.753462032002961032.davem@davemloft.net>
        <20170830094823.GA31503@amd>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
        torvalds@linux-foundation.org, akpm@linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830094823.GA31503@amd> (Pavel Machek's message of "Wed, 30
        Aug 2017 11:48:23 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek <pavel@ucw.cz> writes:

> Could we get this one in?
>
> wl1251 misses a spin_lock_init().
>
> https://www.mail-archive.com/netdev@vger.kernel.org/msg177031.html
>
> It seems pretty trivial, yet getting the backtraces is not nice.

It's in wireless-drivers-next and will be in 4.14-rc1:

https://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git/commit/?id=6e9aae179f290f1a44fce7ef8e9a8e2dd68ed1e4

-- 
Kalle Valo
