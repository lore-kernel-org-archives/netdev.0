From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: suggested forcedeth updates....
Date: Wed, 19 Nov 2003 12:48:45 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031119124845.B7622@sygehus.dk>
References: <BAY2-F101QTmReozTIA0001027c@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexander Zapatka <alexzapatka@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY2-F101QTmReozTIA0001027c@hotmail.com>; from alexzapatka@hotmail.com on Mon, Nov 17, 2003 at 11:07:15PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 17, 2003 at 11:07:15PM -0500, Alexander Zapatka wrote:

> that way you can modprobe/insmod with debug=1 and debuging works... or you 
> can just load it, or load it with debug=0 and no debuging info is printed.
> 
> just thought it might be a nice addition.

Even better would be to use the NETIF_MSG_* flags defined in
linux/netdevice.c and to be able to use ethtool to change the setting at
runtime.

-- 
Regards,
Rask Ingemann Lambertsen
