From: Kumar Gala <kumar.gala@freescale.com>
Subject: Re: [RFC] Patch to Abstract Ethernet PHY support (using driver model)
Date: Thu, 13 Jan 2005 08:45:53 -0600
Message-ID: <D3652CF8-6571-11D9-821C-000393DBC2E8@freescale.com>
References: <FC6D9B81-5514-11D9-8D51-000393C30512@freescale.com> <A3A281FF-5525-11D9-80ED-000393C30512@freescale.com>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Andy Fleming <afleming@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <A3A281FF-5525-11D9-80ED-000393C30512@freescale.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,

We were hoping for more feedback from netdev people on this patch:

http://oss.sgi.com/projects/netdev/archive/2004-12/msg00643.html

thanks

- kumar

On Dec 23, 2004, at 3:00 PM, Andy Fleming wrote:

> It has been suggested that I split the patch into 2 parts: gianfar
> specific stuff, and PHY specific stuff.
>
> Here is the result:
> <gfar_12232004.patch><phy_12232004.patch><ATT229010.txt>
