From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: microchip: enc28j60: use new api
 ethtool_{get|set}_link_ksettings
Date: Sun, 12 Feb 2017 22:34:35 -0500 (EST)
Message-ID: <20170212.223435.2219952332963403246.davem@davemloft.net>
References: <1486674167-19306-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mhei@heimpold.de, sergio.valverde@hpe.com, jarod@redhat.com,
        dompe@hpe.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486674167-19306-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu,  9 Feb 2017 22:02:47 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
