From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Thu, 17 Jun 2004 12:31:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617193154.GE32216@bougret.hpl.hp.com>
References: <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <40D08769.3070106@home.nl> <20040616204248.GA23617@bougret.hpl.hp.com> <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com> <40D0D265.3070804@pobox.com> <20040617174717.GA30460@bougret.hpl.hp.com> <40D1E185.2010201@pobox.com> <20040617185605.GA32216@bougret.hpl.hp.com> <40D1EC54.8000904@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gertjan van Wingerde <gwingerde@home.nl>, sfeldma@pobox.com,
        netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D1EC54.8000904@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 17, 2004 at 03:09:08PM -0400, Jeff Garzik wrote:
>
> >	When I designed the API, I did verify this carefully :
> >	http://marc.theaimsgroup.com/?l=linux-kernel&m=100829443600986&w=2
> 
> This WAS a step forward, and this will help greatly in the 
> implementation of wireless_ops.  It's good stuff, but we are moving 
> forward yet again :)

	And guess what, I'm helping you in the process. Look back at
all the e-mail I sent to the various thread on the subject, and you
will clearly see that I'm constructive and giving suggestion on how to
do best in this process. I even provide patches.
	I don't understand why you are so opposed to my suggestions,
and what more you expect from me.

> If a driver isn't in the kernel, it's the responsibility of the vendor 
> to follow the changes in the kernel.  It's not the kernel developer's 
> responsibility to track random stuff posted on web pages.  That's simply 
> not scalable.

	The wireless extension has remained backward compatible over
almost 8 years, while tremendously improving and adding new
features. And I believe that moving forward, the price of keeping
backward compatibility is small, as you can see from my patch.
	It's possible. It's not difficult. Breaking backward
compatibility is not a design goal.

> I imagine this is another area where we must agree to disagree.  Linux 
> kernel development has always focused on in-tree drivers.
> 
> Wireless traditionally has had a lot of drivers out-of-tree -- and being 
> out of tree, we see what happens:  vendors are encouraged to mixed 
> binary-only drivers, multiple wireless stacks appears, and confusion 
> reigned.

	Jeff, as you know it, I personally added more wireless driver
to the Linux kernel than any other person, for all those reasons. Look
at how Luis R. Rodriguez blame me to have pushed his driver in the
kernel. I've given you plenty of advices on how to move forward with
the in-kernel 802.11 stack, and some of those advices may even have
been helpful.
	So, what are you blaming me of ?

> It's now time for convergence :)

	Converging wireless into Linux since 1996. Welcome to the club ;-)

> 	Jeff

	Jean
