From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the rcu tree
Date: Wed, 8 Mar 2017 12:16:05 +1100
Message-ID: <20170308121605.555a945d@canb.auug.org.au>
References: <20170119143445.6b65dc8b@canb.auug.org.au>
        <CAJzB8QEdnVG8Gy-WOSu1pWTtkeVWgBzZvGCu0nobW3M-hBhpkw@mail.gmail.com>
        <20170213132133.3795849e@canb.auug.org.au>
        <20170213043748.GA30506@linux.vnet.ibm.com>
        <20170213174324.47f1b4f5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paul McKenney <paulmckrcu@gmail.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170213174324.47f1b4f5@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

On Mon, 13 Feb 2017 17:43:24 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> On Sun, 12 Feb 2017 20:37:48 -0800 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> >
> > I chickened out on that commit for this merge window, so it will come
> > back at -rc1.  But I will cover that when I rebase to -rc1.  
> 
> OK, thanks.

[PATCH] smc: merge fix for "mm: Rename SLAB_DESTROY_BY_RCU to SLAB_TYPESAFE_BY_RCU"
is needed again ... maybe time to rebase?

-- 
Cheers,
Stephen Rothwell
