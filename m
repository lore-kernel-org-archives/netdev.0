From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [-mm patch] remove code for WIRELESS_EXT < 18
Date: Sun, 04 Dec 2005 14:33:18 -0500
Message-ID: <4393447E.3020003@pobox.com>
References: <20051203122720.GF31395@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932317AbVLDTdY@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20051203122720.GF31395@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> WIRELESS_EXT < 18 will never be true in the kernel.
> 
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> ---
> 
>  drivers/net/wireless/ipw2100.c           |  434 ----------------------
>  drivers/net/wireless/tiacx/acx_struct.h  |    5 
>  drivers/net/wireless/tiacx/common.c      |    4 
>  drivers/net/wireless/tiacx/conv.c        |    2 
>  drivers/net/wireless/tiacx/ioctl.c       |  441 -----------------------
>  drivers/net/wireless/tiacx/pci.c         |    8 
>  drivers/net/wireless/tiacx/usb.c         |    6 
>  drivers/net/wireless/tiacx/wlan.c        |    2 
>  drivers/net/wireless/tiacx/wlan_compat.h |    9 
>  9 files changed, 1 insertion(+), 910 deletions(-)

NAK, patches non-existent files.

[jgarzik@pretzel linux-2.6]$ ls drivers/net/wireless/tiacx
ls: drivers/net/wireless/tiacx: No such file or directory
