From: jamal <hadi@cyberus.ca>
Subject: Re: in-driver QoS
Date: 11 Jun 2004 08:17:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086956271.1065.651.camel@jzny.localdomain>
References: <20040608184831.GA18462@bougret.hpl.hp.com>
	 <200406092127.28477.vkondra@mail.ru>
	 <1086832740.1205.65.camel@jzny.localdomain>
	 <200406100855.37348.vkondra@mail.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jt@hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200406100855.37348.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-06-10 at 01:55, Vladimir Kondratiev wrote:

> > Vladimir - do you have one of these cards? Jean is putting some my
> > doubts in my mind about their designs. Do they have seperate DMA rings?
>
> Good question. Until I can really answer, let's say "in theory, all next 
> generation wireless cards should have similar design". Hint: I have also mail 
> ending by intel.com

Ok, fine.

> Sounds good. Next step is integrated service, where, prior to use some 
> priority, STA have to allocate bandwidth and get admission from AP.

That part is easy using the current linux qdiscs - the hard part is
getting the separate ids for each FIFO/DMA ring. 

> >
> > Do you wanna try this? I could give you a hand but dont have much time
> > to code at the moment. I could point you to the different pieces of code
> > that need mods and suggest the changes.
>
> It would be great help. Please...
> I promise to share results.

Well, you are doing most of the work;-> Let me knwo when you have the
NIC then we could start. Actually we could discuss even before you get
the NIC; lets take it offline.

cheers,
jamal
