From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC: Network Device Driver Group proposal
Date: Mon, 24 May 2004 13:20:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524132041.46677ed8@dell_ss3.pdx.osdl.net>
References: <20040524084945.GP3330@ruslug.rutgers.edu>
	<20040524113919.3651c453@dell_ss3.pdx.osdl.net>
	<20040524194117.GW3330@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
        Jeff Garzik
 <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
In-Reply-To: <20040524194117.GW3330@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> I think the netdev list is great. In fact, it's superb. But I think network
> driver developers need more than a list. I think it'd be great if we had
> a central group that can serve as resource for legal issues, one which
> would act as a central group to which manufacturers/companies can give
> NDA'd docs to (if this is acceptable; not like I like NDAs) and the
> group could then provide those specs to developers which would then work
> on drivers. Basically I feel we are doing great but we're lacking that
> *corporate* entity any commercial operating system has. Who do
> manufacturers seek out to provide/sell source base/NDA's to so that a
> driver can be written for our OS? No one... On behalf of who does a
> kernel hacker send out an e-mail to a company requesting specs to write
> a driver? The DRI/Xfree86 project have an advantage because of this -- 
> they represent a group who has done tons of great work and companies 
> tend to trust groups more than individuals. Of course, many companies
> are now just takig the initiative to write their own drivers and then
> send 'em away for kernel inclusion. But -- not all do this. An open
> driver needs a mantainer. 

For a lot of reasons, OSDL won't usually sign NDA's especially the boilerplate
kind that most companies provide. The NDA really needs to be with driver
author; even then the restrictions can be unpalatable.

> Having a central place for network drivers would be nice for bugtracking
> as well. Perhaps providing hosting services for network drivers may be a
> good idea too. There are just ideas. I just feel something is missing.

bugme@osdl.org works but the problem with bugtracking systems is that
they tend to be write only.  I.e. bugs go in but nothing comes out.


> If no one has time, I can work on it. I just want to know if this all
> makes sense to others too. Don't *not* reply just because you don't 
> have the time. The work will get done if its for the good.

If you have a more complete proposal, I am not against the idea, just wanted
to make you aware of some of the issues.
