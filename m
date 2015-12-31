From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 5/9] ipw2x00: sdhci-pci: use to_pci_dev()
Date: Thu, 31 Dec 2015 10:30:12 +0200
Message-ID: <87r3i3nhpn.fsf@kamboji.qca.qualcomm.com>
References: <baf4e17c993f197cc31f8a0e5736ee8a558ba44c.1451211133.git.geliangtang@163.com>
	<baf4e17c993f197cc31f8a0e5736ee8a558ba44c.1451211133.git.geliangtang@163.com>
	<896b7d080610c5417a2f09a3bf9d0e20636fcc52.1451211133.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <896b7d080610c5417a2f09a3bf9d0e20636fcc52.1451211133.git.geliangtang-9Onoh4P/yGk@public.gmane.org>
	(Geliang Tang's message of "Sun, 27 Dec 2015 18:46:01 +0800")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org> writes:

> Use to_pci_dev() instead of open-coding it.
>
> Signed-off-by: Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org>

The title is wrong, it should be just "ipw2x00: use to_pci_dev()".

And please state clearly to what tree you are planning to submit these.
I only saw this patch 5, not rest of the patches, so I have no clue
what's going to happen with this patchset. Please resend.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
