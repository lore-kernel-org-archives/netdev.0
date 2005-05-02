From: Patrick McHardy <kaber@trash.net>
Subject: Re: icmp_unreachable uses wrong ip
Date: Mon, 02 May 2005 16:52:06 +0200
Message-ID: <42763E96.1070209@trash.net>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl> <200505021659.05674.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "J. Simonetti" <jeroens@office.netland.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200505021659.05674.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hasso Tepper wrote:
> Similar patches have been posted to the list repeatedly AFAIK with no any 
> response from developers. Can someone enlighten us why? Is there something 
> wrong with it? This is the feature people administrating routers would like 
> to have. It makes debugging complicated topologies much easier and all 
> routers I have seen behave this way.

Why can't you simply add the prefered source address to the route?

Regards
Patrick
