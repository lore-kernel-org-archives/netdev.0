From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH -next 0/4] netfilter reverse path filter matches
Date: Sun, 4 Dec 2011 22:51:50 +0100
Message-ID: <20111204215150.GA28125@1984>
References: <1320877188-1972-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	laforge@netfilter.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1320877188-1972-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Wed, Nov 09, 2011 at 11:19:44PM +0100, Florian Westphal wrote:
> Userspace part is stored in my iptables repository on
> http://git.breakpoint.cc/cgi-bin/gitweb.cgi?p=fw/iptables.git (branch 'xt_rpfilter_9').

I have taken this into iptables, now it is available in the rpfilter
branch.

One inquiry, I need to know copyright / license details for this
extensions/libxt_rpfilter.c

I remember that Harald insisted that having one copyright notice per
.c file is a good practise (even if this doesn't seem to happen in
other iptables extensions files).

No need to resend the patch, I can ammend the patch with the copyright
/ licensing header.

See extensions/libxt_cluster.c for reference.

> Kernel patches are located in the 'xt_rpfilter_9' branch on
> http://git.breakpoint.cc/cgi-bin/gitweb.cgi?p=fw/nf-next.git.

Applied to my nf-next tree.

http://1984.lsi.us.es/git/net-next/

thanks Florian.
