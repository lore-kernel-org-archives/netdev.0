From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: Linux <---> Unixware slow networking with e100
Date: Sun, 9 Nov 2003 12:34:35 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031109123435.B1282@sygehus.dk>
References: <3FA9F8D5.9020601@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Sven Schuster <schuster.sven@gmx.de>
Content-Disposition: inline
In-Reply-To: <3FA9F8D5.9020601@gmx.de>; from schuster.sven@gmx.de on Thu, Nov 06, 2003 at 08:31:33AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 06, 2003 at 08:31:33AM +0100, Sven Schuster wrote:

> But when _receiving_ data from one of the unixware machines, we
> just get a few kB/s, max. about 100 kB/s. When _sending_ data to
> a unixware machine, the transfer rate is fine too. Are there any
> known issues between linux and unixware (except the SCO thing
> ;-) ) ??

Run tcpdump and see what the window sizes are when sending data from
Unixware to Linux.

-- 
Regards,
Rask Ingemann Lambertsen
