From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Thu, 17 Jun 2004 13:46:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617204644.GB3341@bougret.hpl.hp.com>
References: <20040616204248.GA23617@bougret.hpl.hp.com> <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com> <40D0D265.3070804@pobox.com> <20040617174717.GA30460@bougret.hpl.hp.com> <40D1E185.2010201@pobox.com> <20040617185605.GA32216@bougret.hpl.hp.com> <40D1EC54.8000904@pobox.com> <20040617193154.GE32216@bougret.hpl.hp.com> <40D1F687.6030307@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gertjan van Wingerde <gwingerde@home.nl>, sfeldma@pobox.com,
        netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D1F687.6030307@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 17, 2004 at 03:52:39PM -0400, Jeff Garzik wrote:
> 
> I'm _not_ blaming you for anything.  You have certainly contributed a 
> lot.  I've enjoyed working with you in the past, today, and hopefully 
> into the future as well.  I _am_ listening.  But I think we have a 
> fundamental disagreement:
> 
> I feel strongly (as you see :)) that the type-opaque interface has got 
> to go, and that means breaking backwards compatibility in the driver API.

	Jeff, the main disagreement is not about type-opaque versus
strongly-typed interfaces. I gave you a patch to do that, and I told
you you were free to do it the way you want, I would not get in the
way.
	The main disagreement is about backward compatibility. I've
been fighting for 8 years to maintain backward compatibility. I
believe in it, and I not accept gutting it for no good reasons.

> 	Jeff

	Jean
