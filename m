From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Bonding-devel] Re: [RFC][bonding] Improve VLAN support on top
 of bonding
Date: Tue, 15 Jul 2003 18:30:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F14807E.30402@pobox.com>
References: <Pine.LNX.4.44.0307151115500.6012-100000@sasami.anime.net> <Pine.LNX.4.51.0307151434100.4590@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Hollis <goemon@anime.net>, linux-netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0307151434100.4590@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ralph Doncaster wrote:
> On Tue, 15 Jul 2003, Dan Hollis wrote:
> 
> 
>>That is exactly what it does. hw tcp checksumming helps a LOT at gbe rates
> 
> 
> This still doesn't make any sense.  The copy from user-space to kernel
> space does the checksum as far as I recall (unless you use the
> router-not-host kernel build option).


Not for the zero-copy case.

	Jeff
