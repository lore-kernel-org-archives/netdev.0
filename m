From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: netlink tester program
Date: Mon, 2 Jun 2003 20:32:22 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <33001.4.64.196.31.1054611142.squirrel@www.osdl.org>
References: <32804.4.64.196.31.1054351332.squirrel@www.osdl.org>
        <20030530.234211.102567405.davem@redhat.com>
        <20030602140452.039248de.rddunlap@osdl.org>
        <20030602.145619.71112623.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: <rddunlap@osdl.org>, <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <davem@redhat.com>
In-Reply-To: <20030602.145619.71112623.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>    From: "Randy.Dunlap" <rddunlap@osdl.org>
>    Date: Mon, 2 Jun 2003 14:04:52 -0700
>
>    Does anyone have documentation (or semantics) for rtnl_talk()?
>    or just some blurb about it?
>
> I always have to wonder about someone who can't live with just
> working code to study, and absolutely requires some document
> describing it.
>
> What is better or more accurate description than code itself!?!?!

The code is absolute, no doubt about it.  It is the authority.
That doesn't make it right in all cases AFAIK.

And it lacks documentation, even in the source files.
There are no semantics or meaning associated with that code
except by the people who developed it.  I'm not one of them,
so I'm trying to ask them or others who know.

And yes, I'm looking for the way that it should be done (IMHO)
instead of the way it is done.

Now, given that I think that the netlink interface is poorly
documented, and that I'm trying to add some kernel code that
uses it, and that I'm trying to test said kernel code with a
userspace test program, I also plan to add such documentation
that I think is warranted to make it easy to use, even by
non-kernel devevlopers.  This documentation might end up
living outside of the kernel tree -- that's OK.  But in any
case, from both private and mailing list emails, I'm not alone
in thinking that it's needed.

~Randy
