From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] khttpd crash fix
Date: Fri, 27 Sep 2002 23:09:50 -0300 (BRT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0209272309160.17618-100000@freak.distro.conectiva>
References: <Pine.LNX.4.44.0209272304240.17618-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <dank@alumni.caltech.edu>,
   Arjan van de Ven <arjanv@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-bounce@oss.sgi.com>
To: dank@kegel.com
In-Reply-To: <Pine.LNX.4.44.0209272304240.17618-100000@freak.distro.conectiva>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Fri, 27 Sep 2002, Marcelo Tosatti wrote:

>
>
> On Mon, 19 Aug 2002 dank@kegel.com wrote:
>
> > I've been using this patch for some time now; it fixes
> > a nasty oops in khttpd on smp, and adds crucial details to the doc.
> > Sure, khttpd is going away in 2.5, but 2.4 is stable, let's fix it there.
> >
> > I sent it multiple times to the author of khttpd and to the khttpd-users
> > mailing list, and even to linux-kernel; I received good comments
> > from khttpd-users but silence elsewhere.
> > In desperation, I finally read the MAINTAINERS file, and learned that there
> > is no official maintainer for khttpd, so here I am mailing it to the
> > 'mail patches to' address for General Networking Stuff.
> >
> > Any chance this could be blessed for transmission to Marcello for 2.4.20?
>
> I guess Arjan could take a look at the patch, since he is the maintainer.

Or rather, used to be.

Anyway, I already got that fix on my tree thanks to Alan.

Just /dev/null both mails ;)
