From: Fedor Karpelevitch <fedor@karpelevitch.net>
Subject: Re: [PATCH] Re: ifconfig up/down problem
Date: Tue, 9 Sep 2003 23:08:48 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200309092308.48099.fedor@karpelevitch.net>
References: <Pine.LNX.4.56.0309090004100.24700@space.comunit.de> <3F5CFF7E.1090005@pobox.com> <200309091635.58748.fedor@karpelevitch.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>,
	Andrew Morton <akpm@digeo.com>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>,
	Sven-Haegar Koch <haegar@sdinet.de>
In-Reply-To: <200309091635.58748.fedor@karpelevitch.net>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Fedor Karpelevitch wrote:
> Jeff Garzik wrote:
> > Sven-Haegar Koch wrote:
> > > Kernel 2.4.20-pre2-ac3 is ok (my last kernel, running for
> > > month')
> >
> > Does the attached patch fix it?
> >
> > 	Jeff
>
> does not help me (assuming I have the same problem). I have a total
> lockup a few seconds after setting up the interface (not
> immidiately).
>
> Fedor.

actually it seemed to have helped with 2.6.0-test5 where I was 
apparently having the same issue. Not with 2.4.23-pre3 however...

Fedor.
