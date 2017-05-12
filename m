From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: irda: irda-usb: fix firmware name on big-endian
 hosts
Date: Fri, 12 May 2017 12:16:11 -0400 (EDT)
Message-ID: <20170512.121611.799407836371084869.davem@davemloft.net>
References: <20170512101113.1935-1-johan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org, stable@vger.kernel.org,
        nfedchik@atlantic-link.com.ua
To: johan@kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170512101113.1935-1-johan@kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan@kernel.org>
Date: Fri, 12 May 2017 12:11:13 +0200

> Add missing endianness conversion when using the USB device-descriptor
> bcdDevice field to construct a firmware file name.
> 
> Fixes: 8ef80aef118e ("[IRDA]: irda-usb.c: STIR421x cleanups")
> Cc: stable <stable@vger.kernel.org>     # 2.6.18
> Cc: Nick Fedchik <nfedchik@atlantic-link.com.ua>
> Signed-off-by: Johan Hovold <johan@kernel.org>

Applied.
