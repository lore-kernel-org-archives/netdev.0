From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] wlcore: spi: fix build warning caused by redundant variable
Date: Wed, 20 Jul 2016 21:27:53 +0300
Message-ID: <87wpkgqi52.fsf@kamboji.qca.qualcomm.com>
References: <1468999637-31006-1-git-send-email-eyalr@ti.com>
	<8665E2433BC68541A24DFFCA87B70F5B36161A64@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-wireless\@vger.kernel.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree\@vger.kernel.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-spi\@vger.kernel.org" <linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "Reizer\, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8665E2433BC68541A24DFFCA87B70F5B36161A64-1tpBd5JUCm6IQmiDNMet8wC/G2K4zDHf@public.gmane.org>
	(Eyal Reizer's message of "Wed, 20 Jul 2016 07:30:20 +0000")
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

"Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org> writes:

> The ret variable is unused in wlcore_probe_of()
> Remove it for fixing build warning.
>
> Fixes: 01efe65aba65 ("wlcore: spi: add wl18xx support")
> Signed-off-by: Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>

Applied to wireless-drivers-next, thanks.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
