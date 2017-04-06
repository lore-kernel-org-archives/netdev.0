From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: usbnet: Remove unused driver_name
 variable
Date: Thu, 06 Apr 2017 12:26:05 -0700 (PDT)
Message-ID: <20170406.122605.1668279862751646859.davem@davemloft.net>
References: <20170405011657.1637-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oneukum@suse.com,
        linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170405011657.1637-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue,  4 Apr 2017 18:16:57 -0700

> With GCC 6.3, we can get the following warning:
> 
> drivers/net/usb/usbnet.c:85:19: warning: 'driver_name' defined but not
> used [-Wunused-const-variable=]
>  static const char driver_name [] = "usbnet";
>                    ^~~~~~~~~~~
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
