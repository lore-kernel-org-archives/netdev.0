From: jamal <hadi@cyberus.ca>
Subject: Re: "Loopback" route through two cards?
Date: Tue, 3 Sep 2002 07:30:46 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209030729370.7754-100000@shell.cyberus.ca>
References: <20020903050441.4052F2C414@lists.samba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>, <kuznet@ms2.inr.ac.ru>, <anton@samba.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>@shell.cyberus.ca@shell.cyberus.ca
In-Reply-To: <20020903050441.4052F2C414@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Unless you are trying to stress test NAT, i wouldnt go the NAT path.
Have you looked at the packet generator in 2.4.19? With it you can
bypass IP totaly.

cheers,
jamal

On Tue, 3 Sep 2002, Rusty Russell wrote:

> Hi all,
>
> 	I know this is an FAQ, but I never saw an answer I liked.  We
> want to stress-test a couple of gigabit NICs by connecting them to
> each other and routing packets out one and into the other.  Is this
> still impossible without nat?
>
> Rusty.
> --
>   Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
>
