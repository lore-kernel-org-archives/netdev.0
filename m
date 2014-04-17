From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v3 1/4] MAINTAINERS: Add entry for APM X-Gene SoC
 ethernet driver
Date: Wed, 16 Apr 2014 20:18:05 -0700
Message-ID: <1397704685.14062.14.camel@joe-AO725>
References: <1397702368-4846-1-git-send-email-isubramanian@apm.com>
	 <1397702368-4846-2-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org, Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1397702368-4846-2-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-04-16 at 19:39 -0700, Iyappan Subramanian wrote:
> This patch adds a MAINTAINERS entry for APM X-Gene SoC
> ethernet driver.
[]
> diff --git a/MAINTAINERS b/MAINTAINERS
[]
> @@ -686,6 +686,14 @@ S:	Maintained
>  F:	drivers/net/appletalk/
>  F:	net/appletalk/
>  
> +APPLIED MICRO (APM) X-GENE SOC ETHERNET DRIVER
> +M:	Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
> +M:	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
> +M:	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
> +S:	Maintained
> +F:	drivers/net/ethernet/apm/xgene

Please add a terminating slash to show this is a directory.

F:	drivers/net/ethernet/apm/xgene/


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
