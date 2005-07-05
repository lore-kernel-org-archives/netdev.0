From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Tue, 5 Jul 2005 19:34:11 +0200
Message-ID: <20050705173411.GK16076@postel.suug.ch>
References: <20050704.154712.63128211.davem@davemloft.net> <42C9BE69.2070008@cosmosbay.com> <42C9BEF6.4080402@cosmosbay.com> <20050704.160140.21591849.davem@davemloft.net> <42CA390C.9000801@cosmosbay.com> <20050705115108.GE16076@postel.suug.ch> <42CA8555.9050607@cosmosbay.com> <20050705134805.GH16076@postel.suug.ch> <42CAAE2F.5070807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <42CAAE2F.5070807@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Eric Dumazet <42CAAE2F.5070807@cosmosbay.com> 2005-07-05 17:58
> I'm using vanilla 2.6.12 : no -funroll-loop in it. Maybe in your tree, not 
> on 99.9% of 2.6.12 trees.
> 
> Are you suggesting everybody should use this compiler flag ?

> I dont know about loopback optimization, I am not involved with this stuff, 
> maybe you think I'm another guy ?
> 
> It seems to me you give unrelated arguments.

Do as you wish, I don't feel like argueing about micro optimizations.
