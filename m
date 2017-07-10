From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Patch] mqueue: fix netlink sock refcnt and skb refcnt
Date: Mon, 10 Jul 2017 11:09:47 -0700
Message-ID: <CA+55aFzYK_14nuyjrvyxDoSS2rvhcCxOpdbLKqNGuRvwuON9jA@mail.gmail.com>
References: <1499663303-4514-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Manfred Spraul <manfred@colorfullife.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499663303-4514-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This thing is definitely not cc'd to the right people:

On Sun, Jul 9, 2017 at 10:08 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Manfred Spraul <manfred@colorfullife.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Unlike your previous patch, this seems to be more of a generic netlink
interface issue, so you should primarily talk to the networking
people, I'm not sure it makes much sense to cc me/Andrew/Manfred.

             Linus
