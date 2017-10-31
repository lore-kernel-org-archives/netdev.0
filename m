From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: Signed-off-by missing for commit in the net-next
 tree
Date: Mon, 30 Oct 2017 23:20:28 -0700
Message-ID: <1509430828.3828.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171031164019.164de3db@canb.auug.org.au>
         <20171031061429.mtq4tc5kwla7lvwv@deco.navytux.spb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Kirill Smelkov <kirr@nexedi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171031061429.mtq4tc5kwla7lvwv@deco.navytux.spb.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-10-31 at 09:14 +0300, Kirill Smelkov wrote:
> Francois,
> 
> On Tue, Oct 31, 2017 at 04:40:19PM +1100, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Commit
> > 
> >   509708310cf9 ("r8169: Add support for interrupt coalesce tuning (ethtool -C)")
> > 
> > is missing a Signed-off-by from its author (or its author is wrong).
> 
> Could we please get signoff for this your patch from 2012 which I've
> reworked a bit to be commit 509708310cf9 ?
> 
>     	https://www.spinics.net/lists/netdev/msg217984.html
>     	https://www.spinics.net/lists/netdev/msg218207.html
> 
> I was keeping you in To and Cc all the time but got no reply at all since my
> first posting from ~ 1 month ago.

Nothing we can do, patch is merged, we can not modify it anymore.

You provided all the rationale in the changelog, so no worries.
