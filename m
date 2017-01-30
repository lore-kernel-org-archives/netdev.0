From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: 4.9 conntrack performance issues
Date: Mon, 30 Jan 2017 13:21:03 +0100
Message-ID: <20170130122103.2t5ew56sh7fem6ui@alphalink.fr>
References: <1a71d807acf63135bb037c7144fcd8d9@nuclearcat.com>
 <20170130112630.pl2jdegnaydxxdpg@alphalink.fr>
 <c18a30d1b61b758e8de93ea373247da7@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netfilter Devel <netfilter-devel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51095 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753171AbdA3MbF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 07:31:05 -0500
Content-Disposition: inline
In-Reply-To: <c18a30d1b61b758e8de93ea373247da7@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 01:37:43PM +0200, Denys Fedoryshchenko wrote:
> On 2017-01-30 13:26, Guillaume Nault wrote:
> > On Sun, Jan 15, 2017 at 01:05:58AM +0200, Denys Fedoryshchenko wrote:
> > > Hi!
> > > 
> > > Sorry if i added someone wrongly to CC, please let me know, if i
> > > should
> > > remove.
> > > I just run successfully 4.9 on my nat several days ago, and seems
> > > panic
> > > issue disappeared.
> > > 
> > Hi Denys,
> > 
> > After two weeks running Linux 4.9, do you confirm that the original
> > issue[1] is gone?
> > 
> > Regards,
> > 
> > Guillaume
> > 
> > [1]: https://www.spinics.net/lists/netdev/msg410795.html
> Yes, no more reboots at all and 4.9 patched for gc issues seems
> significantly better for NAT performance (CPU load lower almost twice than
> previous kernels, i dont have exact numbers).

Great! Thanks for the feedback.
