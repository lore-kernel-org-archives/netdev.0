From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: Mon, 21 Mar 2005 19:59:36 -0600
Message-ID: <200503211959.36089.jdmason@us.ibm.com>
References: <efe3b00605031021513b7268d1@mail.gmail.com> <efe3b006050320111879022bc2@mail.gmail.com> <1111346944.1094.91.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kosta Todorovic <kostodo@gmail.com>,
        Francois Romieu <romieu@fr.zoreil.com>,
        Ben Greear <greearb@candelatech.com>, jgarzik@pobox.com,
        tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1111346944.1094.91.camel@jzny.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 20 March 2005 01:29 pm, jamal wrote:
> On Sun, 2005-03-20 at 14:18, Kosta Todorovic wrote:
> > > I dont think mii-tool will tell you the truth with these cards.
> > > Like i was saying earlier - they use SYM PHYs.
> >
> > Either way, no traffic moved across them when I tried.
>
> Probably the stats display is your best bet for debugging.
>
> > > Does it work on 32 bit machines? I am assuming when you say "64 bit"
> > > you mean the architecture not PCI bus.
> >
> > Yes it does work on 32bit machines, but with the actual znb.o driver
> > thats supplied by ZNXY.
> > And yes i am refering to architecture and NOT pci bus.
>
> It works just fine for me with 32 bit machine with the standard tulip
> driver(sorry dont have 64 bit - too poor); does it work for you?
> i.e i dont use the Znyx driver at all. I always have mine running
> 100Mbps FDX.

My Linksys NC100 adapter works fine on my Athlon 64 system.  So, it is 
probably an adapter/driver interaction issue, and not a 64bit one.  

Kosta, Can you confrim that the tulip driver works for you on a 32bit system?


> If it works on 32 bit, then it maybe an issue with the tulip driver.
>
> cheers,
> jamal

Thanks,
Jon
