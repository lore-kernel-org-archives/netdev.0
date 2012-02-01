From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/6] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
Date: Wed, 1 Feb 2012 03:53:19 +0100
Message-ID: <20120201025319.GA28455@1984>
References: <1327269381-20748-1-git-send-email-richard@nod.at>
 <1327269381-20748-2-git-send-email-richard@nod.at>
 <CAFLxGvzLvdyyaBvh7LCM2+tTmKobK6n8jTRoH8NXd=MVmN4ocA@mail.gmail.com>
 <alpine.LNX.2.01.1201310208370.7433@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	eric.dumazet@gmail.com
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1201310208370.7433@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 01, 2012 at 02:24:11AM +0100, Jan Engelhardt wrote:
> On Monday 2012-01-30 10:01, richard -rw- weinberger wrote:
> 
> >On Sun, Jan 22, 2012 at 10:56 PM, Richard Weinberger <richard@nod.at> wrote:
> >> ipt_LOG and ip6_LOG have a lot of common code, merge them
> >> to reduce duplicate code.
> >>
> >> Signed-off-by: Richard Weinberger <richard@nod.at>
> >
> >No comments?
> 
> Adding Pablo to Cc.

I expect to have some spare time to look into this soon.

Sorry for the silence, I need to unplug a bit from the mailing
list to push some developments forward, it's hard to make everything
at the same time ;-)
