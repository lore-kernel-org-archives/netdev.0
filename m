From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: smsc: smc91x: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 08 Mar 2017 22:06:06 -0800 (PST)
Message-ID: <20170308.220606.1114101273738934697.davem@davemloft.net>
References: <1488627759-8717-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@fluxnic.net, robert.jarzmik@free.fr, mugunthanvnm@ti.com,
        jarod@redhat.com, felipe.balbi@linux.intel.com,
        rmk+kernel@armlinux.org.uk, fw@strlen.de, jeremy.linton@arm.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488627759-8717-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat,  4 Mar 2017 12:42:39 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
> Changelog:
> v2:
> - also update comment (feeback from Russel King)

Applied.
