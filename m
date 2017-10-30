From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: KASAN: use-after-free Write in detach_if_pending
Date: Mon, 30 Oct 2017 11:27:40 -0700
Message-ID: <1509388060.11887.60.camel@edumazet-glaptop3.roam.corp.google.com>
References: <089e0825d424dfce58055c84205f@google.com>
         <alpine.DEB.2.20.1710291327310.1922@nanos>
         <1509282075.11887.44.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACT4Y+YrZzmn9N5jXH-8+T9P+kbyjstDFAeNooaPdrBbzepH4w@mail.gmail.com>
         <1509381386.11887.46.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACT4Y+bppGVyDVCYa0eL6hG5StSCn35eqH+fjM1LOBu+ktD9rQ@mail.gmail.com>
         <1509384629.11887.50.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACT4Y+bRqQFNg-GL6Cd_gA6ZfJGz6Hb2Dhfjqp5fbvRWb+09Zg@mail.gmail.com>
         <1509385672.11887.57.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACT4Y+ZuuDgUY8B3_YN3YK0dVGfsoUDcAJeFquYDCCUwmT3SUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
        syzbot
        <bot+c0733f3aab92fc116dc1d10d8a25f5bf1f739eff@syzkaller.appspotmail.com>,
        John Stultz <john.stultz@linaro.org>,
        LKML <linux-kernel@vger.kernel.org>, sboyd@codeaurora.org,
        syzkaller-bugs@googlegroups.com, netdev <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+ZuuDgUY8B3_YN3YK0dVGfsoUDcAJeFquYDCCUwmT3SUg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-10-30 at 20:52 +0300, Dmitry Vyukov wrote:

> syz fix: <SHA1>  patch title
> 
> then that's doable. If we agree on this format, then I am ready to
> implement this.

Yes please.

David Miller and Linus never rebase their trees, for good reasons.
