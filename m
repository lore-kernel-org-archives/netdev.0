From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Intel and TOE in the news
Date: Sat, 19 Feb 2005 05:10:07 +0100
Message-ID: <20050219041007.GA17896@xi.wantstofly.org>
References: <4216B62D.6000502@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4216B62D.6000502@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Feb 18, 2005 at 10:44:45PM -0500, Jeff Garzik wrote:

> Intel plans to sidestep the need for separate TOE cards by building this 
> technology into its server processor package - the chip itself, chipset 
> and network controller. This should reduce some of the time a processor 
> typically spends waiting for memory to feed back information and improve 
> overall application processing speeds.

I wonder if they could just take the network processing circuitry from
the IXP2800 (an extra 16-core (!) RISCy processor on-die, dedicated to
doing just network stuff, and a 10gbps pipe going straight into the CPU
itself) and graft it onto the Xeon.

Now _that_ would be something worth experiencing.


--L
