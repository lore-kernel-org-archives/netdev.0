From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: RTL8139
Date: Mon, 15 Dec 2003 20:23:06 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031215202306.A1697@sygehus.dk>
References: <3FDDF085.6060603@secline.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leo Cambilargiu <leo@secline.com.br>
Content-Disposition: inline
In-Reply-To: <3FDDF085.6060603@secline.com.br>; from leo@secline.com.br on Mon, Dec 15, 2003 at 03:33:57PM -0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Dec 15, 2003 at 03:33:57PM -0200, Leo Cambilargiu wrote:

> The module 8139too (2.4.23) doesn't load.  It behaves as though no 
> recognized hardware exists.

Normally the module will load fine even with no supported hardware. At least
PCI drivers tend to work that way.

> Any comments?

Show us the errors you get when you try to load the module. In case the
module does load fine but doesn't recognise your board, send us the output
of "lspci -vvv" (as root).

-- 
Regards,
Rask Ingemann Lambertsen
