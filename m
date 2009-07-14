From: "Zhu, Yi" <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH] imwc3200: move iwmc3200 SDIO ids to sdio_ids.h
Date: Tue, 14 Jul 2009 09:59:43 +0800
Message-ID: <AFAB8585072C7E48BC5C6F9C87F9B79703BA8388BB@pdsmsx502.ccr.corp.intel.com>
References: <1247522953-12702-1-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Winkler, Tomas" <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "Winkler, Tomas" <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org" <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1247522953-12702-1-git-send-email-tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tomas wrote:

> +#define SDIO_VENDOR_ID_INTEL			0x0089
> +#define SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX	0x1402
> +#define SDIO_DEVICE_ID_INTEL_IWMC3200WIFI	0x1403
> +#define SDIO_DEVICE_ID_INTEL_IWMC3200TOP        0x1404

Looks good. Please replace the above spaces with a TAB.

> +#define SDIO_DEVICE_ID_INTEL_IWMC3200BT		0x1406
> 
>  #define SDIO_VENDOR_ID_MARVELL			0x02df
>  #define SDIO_DEVICE_ID_MARVELL_LIBERTAS		0x9103

Thanks,
-yi
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
