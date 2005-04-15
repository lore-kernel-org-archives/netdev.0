From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re : [Prism54-devel] Question on prism54 driver
Date: Fri, 15 Apr 2005 09:54:55 -0700
Message-ID: <20050415165455.GA8741@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: rainer.weikusat@sncag.com, prism54-devel@prism54.org, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rainer Weikusat wrote :
> 
> Jean-Baptiste Note <jean-baptiste.note at wanadoo.fr> writes:
> > Going through the prism54 code for reuse in the softmac driver, i
> > stumbled accross inconsistencies in the queue management functions for
> > the mgmt rx queue and the data rx queue that i cannot understand.
> 
> <sigh>
> No, you are just hacking the code without even having tried to
> understand
> 
> 	a) what it is doing
>       b) why it does this
> [which, "by coincedence", happens to be the reason that this driver is
>  so thouroughly broken]
> </sigh>
> 
> BTW, I shouldn't be telling you how your code works, don't you think
> so?

	Ah ! It's so fun to blast an e-mail and flame away. Now, I'm
sorry to inform you that you got a few important fact wrong, and that
your critics were totally unjustified.
	First, Jean-Baptiste is not the author, nor the maintainer of
the Prism54 driver, and neither a contributor to it. The prism54
driver in the kernel is in no way "his" code. He is developping the
softmac driver, which is another beast entirely.
	Second, he is not hacking the code without trying to
understand. Jean-Baptiste started working on his driver only 2 months
ago, and he is asking questions, which demonstrates that he is trying
and willing to learn. Most of us are still trying to learn...
	Third, the prism54 driver may be broken, the usual procedure
is either to send a patch or report specific bugs to the maintainers
(which Jean-Baptiste is not). I've rarely seen pieces of code which
are bug free, so having bugs in the prism54 is not the end of the
world, they just need to be fixed.

	In any case, thanks a lot for explaining clearly the details
of the pci interface to Jean-Baptiste, in my experience memory
management is confusing for begginers, and I'm sure more people could
benefits from your expertise.

	Regards,

	Jean
