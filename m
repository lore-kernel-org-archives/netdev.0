From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando@oss.ntt.co.jp>
Subject: Re: [PATCH] netfilter/IPv6: initialize TOS field in REJECT target
 module
Date: Fri, 06 May 2011 17:27:10 +0900
Message-ID: <1304670430.6581.45.camel@nexus.oss.ntt.co.jp>
References: <1303461461.3134.15.camel@edumazet-laptop>
	 <4DB61C2C.7060508@netfilter.org> <1303781180.2874.13.camel@nausicaa>
	 <20110425.221744.226775617.davem@davemloft.net>
	 <1303795522.6010.5.camel@nausicaa>  <4DB6E607.6000303@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, jengelh@medozas.de,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4DB6E607.6000303@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-04-26 at 17:34 +0200, Pablo Neira Ayuso wrote:
> On 26/04/11 07:25, Fernando Luis Vazquez Cao wrote:
> > Pablo, could you pull in the two patches below? They have already been
> > acked by Eric. It would be great it we could get them merged for the
> > next -rc and stable releases.
> > 
> > [PATCH] netfilter/IPv6: fix DSCP mangle code
> > [PATCH] netfilter/IPv6: initialize TOS field in REJECT target module
> 
> Patrick is the primary link to take patches, I'm including him in this
> CC. If he experiences any problem, I'll make sure that these hit -rc, so
> never mind.

It seems that the two patches above did not make it into 2.6.39-rc6. Any
chance we can get them merged before 2.6.39 is released?

Thanks,
Fernando

