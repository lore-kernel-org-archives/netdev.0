From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: NAPI 8139too.c for 2.4.23
Date: Mon, 1 Dec 2003 15:55:33 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201205533.GA15846@gtf.org>
References: <20031201205038.GK10711@ovh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Octave <oles@ovh.net>
Content-Disposition: inline
In-Reply-To: <20031201205038.GK10711@ovh.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Dec 01, 2003 at 09:50:38PM +0100, Octave wrote:
> Stephen,
> I get your patch from http://lwn.net/Articles/54815/ for 2.6.X and 
> I rewrote it for 2.4.23. Tested with 2.4.23 on high load servers. I 
> have no more "Too much work at interrupt".                                     
> 
> I dropped it on ftp://ftp.ovh.net/made-in-ovh/8139too.c-2.4-0.9.27
> 
> Hope it helps.
> Octave

Very cool!  Thanks for testing.

Is there any chance you could do some benchmark runs with ttcp or
somesuch?

	Jeff
