From: Alexey Dobriyan <adobriyan@mail.ru>
Subject: Re: [PATCH] /driver/net/wan/sbs520
Date: Mon, 10 Jan 2005 19:47:33 +0200
Message-ID: <200501101947.33917.adobriyan@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adam Anthony <aanthony@sbs.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 10 Jan 2005 07:46:52 -0700, Adam Anthony wrote:

> With the permission of my employer, SBS Technologies, Inc., I have
> released a patch for 2.4 kernels that supports the 520 Series of WAN
> adapters.

My editor shows ^M at the end of every line of new Documentation/Configure.help,
MAINTAINERS (add ~63400 bogus lines!). Please, look at the patch _after_
generating it.

> +obj-$(CONFIG_LANMEDIA)		+=		syncppp.o^M

> +subdir-$(CONFIG_LANMEDIA) += lmc^M

Also random ^M's.
 
--- linux-2.4.28-virgin/drivers/net/wan/sbs520/lnxosl.c
+++ /usr/src/linux-2.4.28/drivers/net/wan/sbs520/lnxosl.c

> +// Programming Language:	C^M
> +// Target Processor:		Any^M
> +// Target Operating System: Linux^M

Well, this is pretty obvious to everyone here. :-)

> +// This software may be used and distributed according to the terms^M
> +// of the GNU General Public License, incorporated herein by reference.^M

Stupid question: do you mean GPL version 2 or something else?

	Alexey
