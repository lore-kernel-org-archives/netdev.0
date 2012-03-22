From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: Tree for Mar 21 (netfilter: xt_LOG.c)
Date: Thu, 22 Mar 2012 12:18:12 +0100
Message-ID: <20120322111812.GA16632@1984>
References: <20120321183906.b901645a8e4b68fdf1ad8754@canb.auug.org.au>
 <4F6A7824.50606@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F6A7824.50606@xenotime.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Randy,

On Wed, Mar 21, 2012 at 05:53:56PM -0700, Randy Dunlap wrote:
> On 03/21/2012 12:39 AM, Stephen Rothwell wrote:
> 
> > Hi all,
> > 
> > Reminder: please do not add stuff destined for v3.5 to linux-next
> > included trees/branches until after v3.4-rc1 has been released.
> > 
> > Changes since 20120320:
> 
> on x86_64:
> 
> xt_LOG.c:(.text+0x6962e): undefined reference to `ip6t_ext_hdr'
> 
> Full randconfig file is attached.

I'll push this to mainstream asap.

https://lkml.org/lkml/2012/3/10/68

Sorry, I forgot to make it.

Thanks.
