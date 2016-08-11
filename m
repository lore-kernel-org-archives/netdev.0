From: <Woojung.Huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>
Subject: RE: [PATCH 08/16] net: usb: lan78xx: don't print error when
 allocating urb fails
Date: Thu, 11 Aug 2016 21:42:21 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D408FAFF8@CHN-SV-EXMX02.mchp-main.com>
References: <1470949539-25392-1-git-send-email-wsa-dev@sang-engineering.com>
 <1470949539-25392-9-git-send-email-wsa-dev@sang-engineering.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470949539-25392-9-git-send-email-wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Wolfram Sang [mailto:wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org]
> Sent: Thursday, August 11, 2016 5:05 PM
> To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Wolfram Sang; Woojung Huh - C21699; UNGLinuxDriver;
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: [PATCH 08/16] net: usb: lan78xx: don't print error when allocating
> urb fails
> 
> kmalloc will print enough information in case of failure.
> 
> Signed-off-by: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
> ---
>  drivers/net/usb/lan78xx.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)

Acked-by: Woojung Huh <woojung.huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
