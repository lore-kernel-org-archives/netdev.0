From: bert hubert <ahu@ds9a.nl>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Mon, 14 Oct 2002 12:38:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021014103855.GA19962@outpost.ds9a.nl>
References: <3DA82269.CBB65E89@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <3DA82269.CBB65E89@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 12, 2002 at 03:23:53PM +0200, Stefan Rompf wrote:

> +CONFIG_LINKWATCH
> +  When this option is enabled, the kernel will forward changes in the
> +  operative ("RUNNING") state of an interface via the netlink socket.
> +  This is most useful when running linux as a router.

I know people who would kill for this feature. So powers that be, please
consider merging.

Is there no quick way of getting all cards using the MII stuff to support
this in one go? mii-diag seems to work on most cards already?

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://www.tk                              the dot in .tk
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
