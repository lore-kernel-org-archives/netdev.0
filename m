From: <Woojung.Huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>
Subject: RE: [PATCH 0/2] lan78xx: Remove trailing underscores from macros
Date: Tue, 6 Sep 2016 23:19:05 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40910FF9@CHN-SV-EXMX02.mchp-main.com>
References: <cover.1473202982.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1473202982.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Joe Perches (2):
>   lan78xx: Remove locally defined trailing underscores from defines and uses
>   microchipphy.h and uses: Remove trailing underscores from defines and
> uses
> 
>  drivers/net/phy/microchip.c  |    4 +-
>  drivers/net/usb/lan78xx.c    |  368 +++++++--------
>  drivers/net/usb/lan78xx.h    | 1068 +++++++++++++++++++++-----------------
> ----
>  include/linux/microchipphy.h |   72 +--
>  4 files changed, 756 insertions(+), 756 deletions(-)

Because there is no specific rule how to name defines, I'm not sure it is worth to change 1000+ lines.
It may be better to set guideline for new submissions.

Welcome any comments.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
