From: jamal <hadi@cyberus.ca>
Subject: Re: e1000 kick
Date: 24 Oct 2004 13:01:40 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098637300.1097.247.camel@jzny.localdomain>
References: <20041011162444.20953.qmail@web80402.mail.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Huang <scott_z_huang@yahoo.com>
In-Reply-To: <20041011162444.20953.qmail@web80402.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Scott,
Sorry to bother you again. I am still trying to evaluate whether i
should go and grab these patches from the unconnected machine.
In other words, they may not be useful for you.
Is this a proprieatry stack, something you are researching. what?
How do you pass the packets from user space straight to DMA?

cheers,
jamal

On Mon, 2004-10-11 at 12:24, Scott Huang wrote:
> Hi Jamal,
> 
> I would like to DMA packets to/from pre-allocated
> fixed-sized buffer pools for a user space TCP/IP stack
> to transmit/receive packets. The Rx path is working
> well. I wanted to control when the card should DMA
> packets from the Tx pool. 
> 
> thanks 
> 
> -Scott
> 
> 
> --- jamal <hadi@cyberus.ca> wrote:
> 
> > What are you trying to do?
> > I have some patches i wouldnt mind passing on for
> > test purposes
> > but it would depend on what the end goal is,
> > 
> > cheers,
> > jamal
> > 
> > On Fri, 2004-10-08 at 19:17, Scott Huang wrote:
> > > Hi folks,
> > > 
> > > Is there a way to force tx dma to start on e1000
> > after
> > > the I fill up the tx ring to a certain level?
> > > 
> > > thanks
> > > 
> > > -Scott
> > > 
> > > 
> > > 
> > 
> > 
> 
> 
> 
