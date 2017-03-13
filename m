From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: r8152: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 13 Mar 2017 15:26:40 -0700 (PDT)
Message-ID: <20170313.152640.1055992263781013534.davem@davemloft.net>
References: <1489354918-6650-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, jarod@redhat.com,
        mario_limonciello@dell.com, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489354918-6650-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 12 Mar 2017 22:41:58 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
