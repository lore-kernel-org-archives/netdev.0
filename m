From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next 0/4] netfilter reverse path filter matches
Date: Mon, 5 Dec 2011 09:33:02 +0100
Message-ID: <20111205083302.GA24483@Chamillionaire.breakpoint.cc>
References: <1320877188-1972-1-git-send-email-fw@strlen.de>
 <20111204215150.GA28125@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, laforge@netfilter.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111204215150.GA28125@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Wed, Nov 09, 2011 at 11:19:44PM +0100, Florian Westphal wrote:
> > Userspace part is stored in my iptables repository on
> > http://git.breakpoint.cc/cgi-bin/gitweb.cgi?p=fw/iptables.git (branch 'xt_rpfilter_9').
> 
> I have taken this into iptables, now it is available in the rpfilter
> branch.

Thanks Pablo.

> One inquiry, I need to know copyright / license details for this
> extensions/libxt_rpfilter.c
> 
[..]
> No need to resend the patch, I can ammend the patch with the copyright
> / licensing header.
> 
> See extensions/libxt_cluster.c for reference.

In this case, please amend it to include the same GPL-2 boilerplate
as libxt_cluster.c has.

Thanks,
Florian
