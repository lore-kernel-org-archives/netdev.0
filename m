From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: asix88179_178a: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 13 Mar 2017 15:26:30 -0700 (PDT)
Message-ID: <20170313.152630.471464390835280131.davem@davemloft.net>
References: <1489338156-18632-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, chris.roth@usask.ca, allan@asix.com.tw,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489338156-18632-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 12 Mar 2017 18:02:36 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
