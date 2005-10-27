From: Bongani Hlope <bonganilinux@mweb.co.za>
Subject: Re: <REAL> iBurst (TM) compatible driver
Date: Thu, 27 Oct 2005 23:25:20 +0200
Message-ID: <200510272325.20432.bonganilinux@mweb.co.za>
References: <4cd031a50510270924r38ad4d5oa88ae92a514df3cf@mail.gmail.com> <20051027170727.GA26569@tuxdriver.com> <200510271944.12452.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Nicholas Jefferson <xanthophile@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932640AbVJ0VY3@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200510271944.12452.ak@suse.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 27 October 2005 19:44, Andi Kleen wrote:
> On Thursday 27 October 2005 19:07, John W. Linville wrote:
> > On Fri, Oct 28, 2005 at 02:24:20AM +1000, Nicholas Jefferson wrote:
> > > The latest release of the iBurst (TM) compatible driver [1] for the
> > > 2.6 kernel is now available. Thanks to ArrayComm (R) for the original
> >
> > <snip>
> >
> > > Signed-off-by: Nicholas Jefferson <xanthophile@gmail.com>
> >
> > -ENOPATCH?
>
> And no description what an "iBurst (tm)" actually is. It sounds like
> something to clear blocked drains with.
>
> -Andi

iBurst is a wireless broadband internet service, so far I only know that it is 
available in Austrailer and South Africa. Here in South Africa, there are two 
devices you can use for connectivity an internal and external "modem". With 
the external modem, you can use either  USB or ethernet to connect (pppoe). 
The PCMCIA currently is not documented and there is no driver for Linux.

I ordered the external modem (still waiting for it), I'll try to get some guys 
from our LUG to test it (only the PCMCIA version is causing pain), hopefuly 
someone is stuck with that version ;)
