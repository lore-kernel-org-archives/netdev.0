From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: adm80211: add checks for dma mapping errors
Date: Mon,  5 Dec 2016 11:11:09 +0000 (UTC)
Message-ID: <20161205111109.14716614F9@smtp.codeaurora.org>
References: <1480715566-17027-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ldv-project-tpLiQldItUH5n4uC9ZG1Ww@public.gmane.org
To: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1480715566-17027-1-git-send-email-khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org> wrote:
> The driver does not check if mapping dma memory succeed.
> The patch adds the checks and failure handling.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>

Patch applied to wireless-drivers-next.git, thanks.

d15697de60db adm80211: add checks for dma mapping errors

-- 
https://patchwork.kernel.org/patch/9459295/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
