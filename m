From: Paul Jakma <paul@clubi.ie>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 21:04:38 +0100 (IST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org>
References: <4148991B.9050200@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: leonid.grossman@s2io.com, Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
In-Reply-To: <4148991B.9050200@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004, Jeff Garzik wrote:

> Put simply, the "ultimate TOE card" would be a card with network ports, a 
> generic CPU (arm, mips, whatever.), some RAM, and some flash.  This card's 
> "firmware" is the Linux kernel, configured to run as a _totally indepenent 
> network node_, with IP address(es) all its own.
>
> Then, your host system OS will communicate with the Linux kernel running on 
> the card across the PCI bus, using IP packets (64K fixed MTU).

> My dream is that some vendor will come along and implement such a 
> design, and sell it in enough volume that it's US$100 or less. 
> There are a few cards on the market already where implementing this 
> design _may_ be possible, but they are all fairly expensive.

The intel IXP's are like the above, XScale+extra-bits host-on-a-PCI 
card running Linux. Or is that what you were referring to with 
"<cards exist> but they are all fairly expensive."?

> 	Jeff

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
There is nothing so easy but that it becomes difficult when you do it
reluctantly.
 		-- Publius Terentius Afer (Terence)
