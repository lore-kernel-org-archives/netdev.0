From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Sun, 12 Sep 2004 17:13:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040912171316.1fbdf8db.davem@davemloft.net>
References: <E1C4wYe-0005qT-00@gondolin.me.apana.org.au>
	<20040908072408.GI27886@wotan.suse.de>
	<1094629677.1089.155.camel@jzny.localdomain>
	<20040908134713.1bcd46d3.davem@davemloft.net>
	<1094823215.1121.129.camel@jzny.localdomain>
	<20040911142116.GL4431@wotan.suse.de>
	<1094933731.2343.109.camel@jzny.localdomain>
	<20040911174535.2acbb957.davem@davemloft.net>
	<20040912100114.GB11484@havoc.gtf.org>
	<20040912102529.GA27096@wotan.suse.de>
	<20040912110320.GA21197@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, hadi@cyberus.ca, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040912110320.GA21197@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 12 Sep 2004 13:03:20 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Andi Kleen <ak@suse.de> :
> [...]
> > I wasn't aware of Documentation/netdevices.txt, but I agree it 
> > would be a good idea to update it. Patch for that attached.
> > DaveM, please apply.
> 
> I have modified your patch so as to include a bit from a message
> of Jamal on netdev the 05/07/2004.

I've enhanced it further to make use of the macro'ized
named Jamal added for these values.

Thanks everyone.
