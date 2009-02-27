From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] iptables: new strict host model match
Date: Fri, 27 Feb 2009 09:30:32 +0100 (CET)
Message-ID: <alpine.DEB.2.00.0902270908330.10479@blackhole.kfki.hu>
References: <20090226175247.5e56910f@nehalam> <alpine.LSU.2.00.0902270414290.14912@fbirervta.pbzchgretzou.qr> <20090226192353.2b6dea9f@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090226192353.2b6dea9f@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Feb 2009, Stephen Hemminger wrote:

> On Fri, 27 Feb 2009 04:16:19 +0100 (CET)
> Jan Engelhardt <jengelh@medozas.de> wrote:
> 
> > This looks easy enough to also do for IPv6. Would you?
> 
> IPV6 already does this.

Still, it'd worth, because for example non-matching IPv4/IPv6 packets 
could then be logged together.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
