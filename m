From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: Fw: [Bug 4279] New: When I try to start vpnc the net/core/skbuff.c:91
 crash
Date: Fri, 04 Mar 2005 10:05:08 -0800
Message-ID: <4228A354.8020904@qualcomm.com>
References: <20050303095832.6a084856@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050303095832.6a084856@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Stephen,

> Looks like a something wrong with tun driver on 2.6.11

Thanks for forwarding this. I'll take a look at it.
As far as I remember nothing really changed in the TUN write logic.
Must be some other changes broke it.

Max
