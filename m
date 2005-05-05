From: Andi Kleen <ak@muc.de>
Subject: Re: (diet-)FIB alternative fib_hlist.c
Date: 5 May 2005 20:07:43 +0200
Message-ID: <20050505180743.GC24386@muc.de>
References: <17016.62444.34282.625407@robur.slu.se> <m1zmvax2cx.fsf@muc.de> <1115297370.7680.58.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, Jens.Laas@data.slu.se,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 5 May 2005 20:07:43 +0200
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115297370.7680.58.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Great patch it is - but why do you say "99.999% of all users" feel they
> would love this? Clearly perfomance at the low routes area is not

What I wanted to say is that 99.999% of all users dont need the
cisco grade BGP4 capable standard FIB, it is a just wasted complexity
and memory for them.

> something that is a huge difference against standard fib. And you suffer
> miserably at latge route size.
> Is it memory consumption you are thinking of?

Yes, and complexity.

-Andi
