From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] net: smsc: smc91x: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 04 Mar 2017 21:27:51 +0100
Message-ID: <87k284wzw8.fsf@belgarion.home>
References: <1488622292-13200-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nico@fluxnic.net, davem@davemloft.net, mugunthanvnm@ti.com,
        jarod@redhat.com, felipe.balbi@linux.intel.com,
        rmk+kernel@armlinux.org.uk, fw@strlen.de, jeremy.linton@arm.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488622292-13200-1-git-send-email-tremyfr@gmail.com> (Philippe
        Reynes's message of "Sat, 4 Mar 2017 11:11:32 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philippe Reynes <tremyfr@gmail.com> writes:

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
>
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
I have the hardware.

Do you want anything specific to be tested, like setting full/half duplex or
autoneg through ethtool, or just a driver probe/usage ?

Cheers.

-- 
Robert
