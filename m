From: bert hubert <ahu@ds9a.nl>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Mon, 14 Oct 2002 13:11:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021014111155.GB20397@outpost.ds9a.nl>
References: <3DA82269.CBB65E89@isg.de> <20021014103855.GA19962@outpost.ds9a.nl> <15786.42910.601886.468716@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <15786.42910.601886.468716@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 14, 2002 at 01:16:46PM +0200, Robert Olsson wrote:

>  If you run a routing protocol BGP, OSPF etc it has it's own mechanism
>  with timers for declaring neighbours/link partners down. But yes in some
>  setups it can be useful -- with dampning.

I bet Zebra would like to use this. I also know people who want to use this
to change their own routes to, say, an alternate interface.

>  PS. Have seen 100 kpps in a Linux production router now. :-)

With a bgp full view? 100kpps is not all that impressive in itself isn't it?
We benchmarked our nameserver at 120kpps recently and linux seemed
unimpressed :-)

Regards,

bert hubert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://www.tk                              the dot in .tk
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
