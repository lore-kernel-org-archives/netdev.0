From: Fedor Karpelevitch <fedor@karpelevitch.net>
Subject: Re: [PATCH] Re: ifconfig up/down problem
Date: Wed, 10 Sep 2003 07:52:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309100752.19594.fedor@karpelevitch.net>
References: <Pine.LNX.4.56.0309090004100.24700@space.comunit.de> <200309091635.58748.fedor@karpelevitch.net> <200309092308.48099.fedor@karpelevitch.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>,
   Andrew Morton <akpm@digeo.com>, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Sven-Haegar Koch <haegar@sdinet.de>
In-Reply-To: <200309092308.48099.fedor@karpelevitch.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fedor Karpelevitch wrote:
> Fedor Karpelevitch wrote:
> > Jeff Garzik wrote:
> > > Sven-Haegar Koch wrote:
> > > > Kernel 2.4.20-pre2-ac3 is ok (my last kernel, running for
> > > > month')
> > >
> > > Does the attached patch fix it?
> > >
> > > 	Jeff
> >
> > does not help me (assuming I have the same problem). I have a
> > total lockup a few seconds after setting up the interface (not
> > immidiately).
> >
> > Fedor.
>
> actually it seemed to have helped with 2.6.0-test5 where I was
> apparently having the same issue. Not with 2.4.23-pre3 however...
>
> Fedor.

I am really sorry for giving all this misleading information but now 
it works fine for me with 2.4.23-pre3 as well, but I bet it did lock 
up the first time I tried it. So there may be something wrong with me 
or it is some other random problem I am seeing...

Fedor
