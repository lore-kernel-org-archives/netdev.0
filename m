From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: suggested forcedeth updates....
Date: Wed, 19 Nov 2003 09:06:37 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBB78ED.8050701@pobox.com>
References: <BAY2-F101QTmReozTIA0001027c@hotmail.com> <20031119124845.B7622@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Zapatka <alexzapatka@hotmail.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031119124845.B7622@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rask Ingemann Lambertsen wrote:
> On Mon, Nov 17, 2003 at 11:07:15PM -0500, Alexander Zapatka wrote:
> 
> 
>>that way you can modprobe/insmod with debug=1 and debuging works... or you 
>>can just load it, or load it with debug=0 and no debuging info is printed.
>>
>>just thought it might be a nice addition.
> 
> 
> Even better would be to use the NETIF_MSG_* flags defined in
> linux/netdevice.c and to be able to use ethtool to change the setting at
> runtime.


agreed...
