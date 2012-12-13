From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 12 Dec 2012 18:15:04 -0800
Message-ID: <CA+55aFwzUgxQAze=mYbEx8b61V542tzm06Df=mR1BtYVbJy0mg@mail.gmail.com>
References: <20121212.151116.143443755590581447.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121212.151116.143443755590581447.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 12, 2012 at 12:11 PM, David Miller <davem@davemloft.net> wrote:
>
> There is one merge conflict to resolve in net/sched/cls_cgroup.c,
> one commit changes the name of some members to "css_*" (this came
> from Tejun's tree) and another commit adds an "attach" method.

There's more than that. The ARM board mess is apparently now affecting
the networking merges too.

I fixed it up. Hopefully correctly.

Also, why does the new SHA1 hmac cookie support default to 'y'?

                  Linus
