From: jamal <hadi@cyberus.ca>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: 20 Mar 2005 14:38:23 -0500
Message-ID: <1111347503.1095.101.camel@jzny.localdomain>
References: <efe3b00605031021513b7268d1@mail.gmail.com>
	 <200503182333.51470.jdmason@us.ibm.com>
	 <efe3b0060503190229dff2a01@mail.gmail.com>
	 <200503190757.27727.jdmason@us.ibm.com>
	 <20050319152354.GA4946@electric-eye.fr.zoreil.com>
	 <1111327546.1094.47.camel@jzny.localdomain>
	 <efe3b006050320110226b2dba1@mail.gmail.com>
	 <1111345791.1095.86.camel@jzny.localdomain>
	 <efe3b006050320111879022bc2@mail.gmail.com>
	 <1111346944.1094.91.camel@jzny.localdomain>
	 <efe3b00605032011365dac3539@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, Jon Mason <jdmason@us.ibm.com>,
        Ben Greear <greearb@candelatech.com>, jgarzik@pobox.com,
        tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
To: Kosta Todorovic <kostodo@gmail.com>
In-Reply-To: <efe3b00605032011365dac3539@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Your best is to get the tulip driver working. The card is EOLed;
Also if you can (If Donald still does this) try out Donalds version of
the driver.

cheers,
jamal

On Sun, 2005-03-20 at 14:36, Kosta Todorovic wrote:
> I'm not sure if the tulip driver works in 32bit mode. I know that the
> znb driver works.
> I will check the tulip driver in 32bit mode tomorrow and let you know.
> 
> 
> On 20 Mar 2005 14:29:04 -0500, jamal <hadi@cyberus.ca> wrote:
> > On Sun, 2005-03-20 at 14:18, Kosta Todorovic wrote:
> > > > I dont think mii-tool will tell you the truth with these cards.
> > > > Like i was saying earlier - they use SYM PHYs.
> > >
> > > Either way, no traffic moved across them when I tried.
> > >
> > 
> > Probably the stats display is your best bet for debugging.
> > 
> > > > Does it work on 32 bit machines? I am assuming when you say "64 bit" you
> > > > mean the architecture not PCI bus.
> > >
> > > Yes it does work on 32bit machines, but with the actual znb.o driver
> > > thats supplied by ZNXY.
> > > And yes i am refering to architecture and NOT pci bus.
> > 
> > It works just fine for me with 32 bit machine with the standard tulip
> > driver(sorry dont have 64 bit - too poor); does it work for you?
> > i.e i dont use the Znyx driver at all. I always have mine running
> > 100Mbps FDX.
> > 
> > If it works on 32 bit, then it maybe an issue with the tulip driver.
> > 
> > cheers,
> > jamal
> > 
> >
> 
