From: Scott Huang <scott_z_huang@yahoo.com>
Subject: Re: e1000 kick
Date: Mon, 11 Oct 2004 09:24:44 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041011162444.20953.qmail@web80402.mail.yahoo.com>
References: <1097444592.1049.228.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1097444592.1049.228.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi Jamal,

I would like to DMA packets to/from pre-allocated
fixed-sized buffer pools for a user space TCP/IP stack
to transmit/receive packets. The Rx path is working
well. I wanted to control when the card should DMA
packets from the Tx pool. 

thanks 

-Scott


--- jamal <hadi@cyberus.ca> wrote:

> What are you trying to do?
> I have some patches i wouldnt mind passing on for
> test purposes
> but it would depend on what the end goal is,
> 
> cheers,
> jamal
> 
> On Fri, 2004-10-08 at 19:17, Scott Huang wrote:
> > Hi folks,
> > 
> > Is there a way to force tx dma to start on e1000
> after
> > the I fill up the tx ring to a certain level?
> > 
> > thanks
> > 
> > -Scott
> > 
> > 
> > 
> 
> 
