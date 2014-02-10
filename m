From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] USB2NET : SR9800 : One chip USB2.0 USB2NET SR9800
 Device Driver Support
Date: Sun, 09 Feb 2014 18:08:59 -0800 (PST)
Message-ID: <20140209.180859.1874072271513266305.davem@davemloft.net>
References: <1391755365-9202-1-git-send-email-liujunliang_ljl@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, horms@verge.net.au, romieu@fr.zoreil.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	sunhecheng@vip.126.com
To: liujunliang_ljl@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391755365-9202-1-git-send-email-liujunliang_ljl@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: liujunliang_ljl@163.com
Date: Fri,  7 Feb 2014 14:42:45 +0800

> +MODULE_AUTHOR("Liu Junliang <liujunliang_ljl@163.com");
> +MODULE_VERSION(DRIVER_VERSION);
> +MODULE_DESCRIPTION("SR9800 USB 2.0 USB2NET Dev : http://www.corechip-sz.com");
> +MODULE_LICENSE("GPL");
> +

Please do not add empty lines at the end of files.
