From: Ben Greear <greearb@candelatech.com>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: Thu, 10 Mar 2005 22:00:23 -0800
Message-ID: <423133F7.7040400@candelatech.com>
References: <efe3b00605031021513b7268d1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
To: Kosta Todorovic <kostodo@gmail.com>
In-Reply-To: <efe3b00605031021513b7268d1@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kosta Todorovic wrote:
> My company has recently purchased several ZNYX ZX274 network cards.
> These cards are Four Channel, 10/100 PCI Adapters. They use Intel chipsets.
> 
> Unfortunately there exists no drivers for linux amd64 architecture.
> There are 32bit drivers found at:
> http://www.znyx.com/support/drivers/ZX374_drivers.htm but naturally
> they wont compile under my amd64 system.
> 
> The driver itself is called znb.o and can be downloaded from ZNYX's
> website. I spoke to support staff there but they told me they have
> discontinued support and development for this series of cards.
> 
> The system I am running gentoo and have tried both 2.4.x and 2.6.x
> kernels but no luck.
> 
> Unfortunately there is NO 64bit drivers available for ANY platform. not even MS.
> 
> Does anyone know of a customised znb.o driver built for amd64?
> Is there any chance of anyone modifying the source code of the driver
> to compile under a amd64 system?
> 
> I've noticed that "tulip" drivers get loaded as a module at boot time.
> but they dont function correctly. (lets you start the device and
> attach ips but cant talk through it)
> 
> Is there any variants of the tulip driver that will work for this?
> 
> Help much appreciated.

My personal opinion is that those NICs suck.  I never did get mine
to work.  I'd suggest getting a DFE-570tx if you can find it, or
perhaps a p430tx.  You can also get 4-port GigE NICs from Intel for
around $400 these days...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
