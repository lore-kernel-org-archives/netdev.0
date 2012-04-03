From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] tilepro ethernet driver: fix a few minor issues
Date: Tue, 03 Apr 2012 16:01:28 -0700
Message-ID: <1333494088.2695.29.camel@joe2Laptop>
References: <201203302325.q2UNPm8j012403@farm-0012.internal.tilera.com>
	 <20120403.182335.782073108961783777.davem@davemloft.net>
	 <20120404083738.0b0f09ffc1f8c5a105c240eb@canb.auug.org.au>
	 <20120403.184004.2056266545823149252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, cmetcalf@tilera.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120403.184004.2056266545823149252.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-04-03 at 18:40 -0400, David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 4 Apr 2012 08:37:38 +1000
> > On Tue, 03 Apr 2012 18:23:35 -0400 (EDT) David Miller <davem@davemloft.net> wrote:
> >> Format the comment:
> >> 	/* Like
> >> 	 * this.
> >> 	 */
> >> not:
> >> 	/*
> >> 	 * Like
> >> 	 * this.
> >> 	 */
> > People may be confused because Documentation/CodingStyle says to use the
> > latter ...
> I refuse to be dragged into this conversation, I'm completely aware
> of the exact situation and I've stated my peace on this time and time
> again.

I think you'd have less overall upset in yourself and in
other people if you would do more than repeat yourself
on patch submissions via mailing lists.

To my knowledge when the comment block style was added to
CodingStyle in 2006, you didn't mention anything about it.

https://lkml.org/lkml/2006/12/7/41

and I don't see any other mentions from you.

When I suggested adding something specifically for net
and drivers/net, you were at least dispraising.

http://lists.openwall.net/netdev/2012/02/04/59

I think it'd be useful to have this preference you have
for block comment style written out somewhere other than
the email archives.

cheers, Joe
