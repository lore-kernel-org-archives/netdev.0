From: Deepak Saxena <dsaxena@plexity.net>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 14:36:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915213600.GA12153@plexity.net>
References: <4148991B.9050200@pobox.com> <Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org>
Reply-To: dsaxena@plexity.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>, leonid.grossman@s2io.com,
        Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Jakma <paul@clubi.ie>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sep 15 2004, at 21:04, Paul Jakma was caught saying:
> On Wed, 15 Sep 2004, Jeff Garzik wrote:
> 
> >Put simply, the "ultimate TOE card" would be a card with network ports, a 
> >generic CPU (arm, mips, whatever.), some RAM, and some flash.  This card's 
> >"firmware" is the Linux kernel, configured to run as a _totally indepenent 
> >network node_, with IP address(es) all its own.
> >
> >Then, your host system OS will communicate with the Linux kernel running 
> >on the card across the PCI bus, using IP packets (64K fixed MTU).
> 
> >My dream is that some vendor will come along and implement such a 
> >design, and sell it in enough volume that it's US$100 or less. 
> >There are a few cards on the market already where implementing this 
> >design _may_ be possible, but they are all fairly expensive.
> 
> The intel IXP's are like the above, XScale+extra-bits host-on-a-PCI 
> card running Linux. Or is that what you were referring to with 
> "<cards exist> but they are all fairly expensive."?

Unfortunately all the SW that lets one make use of the interesting
features of the IXPs (microEngines, crypto, etc) is a pile of
propietary code.

~Deepak


-- 
Deepak Saxena - dsaxena at plexity dot net - http://www.plexity.net/

"Unlike me, many of you have accepted the situation of your imprisonment
and will die here like rotten cabbages." - Number 6
