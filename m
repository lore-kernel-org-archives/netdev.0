From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: Raylink/WebGear testing - ray_cs.c iomem bug?
Date: Fri, 8 Oct 2004 15:08:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008220801.GA2219@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote :
> 
> Still, I'd love to have somebody verify that the cleaned-up version 
> (without any changes) still works. It should be 100% equivalent to the old 
> one, but it's good to make sure.
> 
> 		Linus

	I have a couple of Netgear cards, and my laptops are more or
less configured properly to test them. It's actually been a while I
got those cards out of their box, and I'm not even sure the driver
works properly in 2.6.X.
	In any case, would you mind sending the patch directly to me,
I don't feel like trying to recover it from the mailing list archive
(space vs. tab, wrapping and all that junk).
	Thanks...

	Jean
