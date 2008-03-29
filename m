From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Sat, 29 Mar 2008 11:35:35 +0200
Message-ID: <20080329093536.M90997@visp.net.lb>
References: <20080328132359.15573601@speedy> <20080328203358.M8487@visp.net.lb> <47ED6066.2010407@cosmosbay.com> <20080328.162137.132976647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080328.162137.132976647.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I checked whole night, shame on me. Seems this patch was curing the problem.
Probably it was rejected, and i didn't notice. I will be more careful, sorry 
again.

On Fri, 28 Mar 2008 16:21:37 -0700 (PDT), David Miller wrote
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 28 Mar 2008 22:17:26 +0100
> 
> > Denys Fedoryshchenko a :
> > > It seems or patch change something (but it is just showing debug, 
strange), 
> > > or there is something fixed between 2.6.25-rc7-git1 and 2.6.25-rc7-
git3. LC-
> > > trie working fine, HASH also i cannot see any leaks.
> > 
> > Yes, the fix is the patch we mentioned yesterday, and you told us you 
tried it :(
> 
> Denys please be more careful in the future :-(
> 
> So much time and effort got wasted because of this.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

