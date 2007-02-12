From: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel PRO/Wireless 3945ABG
Date: Mon, 12 Feb 2007 10:35:15 -0800
Message-ID: <45D0B363.8070303@linux.intel.com>
References: <45CCE3CA.4050904@linux.intel.com> <200702101424.00156.mail@earthworm.de> <200702101525.56820.mail@earthworm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Hesse, Christian" <mail-8oMOrB1mGocUSW6y5lq3GQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200702101525.56820.mail-8oMOrB1mGocUSW6y5lq3GQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hesse, Christian wrote:
> On Saturday 10 February 2007 14:23, Hesse, Christian wrote:
>> On Friday 09 February 2007 22:12, James Ketrenos wrote:
>>> We are pleased to announce the availability of a new driver for the
>>> Intel PRO/Wireless 3945ABG Network Connection adapter.
...
> Oh, I forgot one note: "make patch_kernel" is terribly broken. Any chance to 
> get this fixed soon?

I've put up a new version of iwlwifi (0.0.6) with significant changes to 
the patch_kernel scripts as well as including Pavel's patch to KSRC.

I performed some build testing with 2.6.18 and wireless-dev @ commit 
f66e5aaa88c1c0a7ee6c6427d6535ed8afd35427 (Jan 8).

http://intellinuxwireless.org/?n=downloads

Let me know if it is still breaking.

Thanks,
James
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
