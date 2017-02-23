From: Florian Westphal <fw@strlen.de>
Subject: Re: netfilter: nft_ct: add zone id set support
Date: Thu, 23 Feb 2017 12:49:30 +0100
Message-ID: <20170223114930.GG11144@breakpoint.cc>
References: <20170222190219.EC87B661B65@gitolite.kernel.org>
 <CAMuHMdUJ=2+9ko0KEU7rX3rb7vghNj3Xc-HSLSK=-kqQ+CZM6w@mail.gmail.com>
 <20170223113435.GF11144@breakpoint.cc>
 <20170223114216.GA3093@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170223114216.GA3093@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Thu, Feb 23, 2017 at 12:34:35PM +0100, Florian Westphal wrote:
> > Yes, Dan reported this and a patch is queued at
> > http://patchwork.ozlabs.org/patch/727573/
> > 
> > Pablo, any reason why this is still waiting?
> 
> I just flushing out my nf.git tree via pull request.
> 
> Once these changes are pulled, I'll fetch recent net-next changes that
> were just merged via net. Then, I'll pick this so we can calm down
> these compilation warnings.
> 
> Are you OK with this procedure? Thanks!

Sure.
