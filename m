From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/usb/hso: Add support for Option GTM671WFS
Date: Tue, 05 Aug 2014 13:06:35 -0700 (PDT)
Message-ID: <20140805.130635.2042284107609253943.davem@davemloft.net>
References: <1407143509-27683-1-git-send-email-ricardo.ribalda@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.dumon@option.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dcbw@redhat.com
To: ricardo.ribalda@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407143509-27683-1-git-send-email-ricardo.ribalda@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Date: Mon,  4 Aug 2014 11:11:49 +0200

> After this patch:
> 
> [   32.985530] hso: drivers/net/usb/hso.c: Option Wireless
> [   33.000452] hso 2-1.4:1.7: Not our interface
> [   33.001849] usbcore: registered new interface driver hso
> 
> root@qt5022:~# ls /dev/ttyHS*
> /dev/ttyHS0  /dev/ttyHS1  /dev/ttyHS2  /dev/ttyHS3  /dev/ttyHS4
> /dev/ttyHS5
> 
> root@qt5022:~# lsusb -d 0af0: -vvv
 ...
> Signed-off-by: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>

Applied, thanks.
