From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [1/3] hostap: Use memdup_user() rather than duplicating its
 implementation
Date: Mon, 26 Sep 2016 14:19:44 +0000 (UTC)
Message-ID: <20160926141944.A5DA06151E@smtp.codeaurora.org>
References: <efa66c16-7998-9ceb-0be6-d62dd249a2dc@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Jouni Malinen <j@w1.fi>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
To: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <efa66c16-7998-9ceb-0be6-d62dd249a2dc-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org> wrote:
> From: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> Date: Sat, 20 Aug 2016 18:19:43 +0200
> 
> Reuse existing functionality from memdup_user() instead of keeping
> duplicate source code.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>

Patch set to Rejected.

[1/3] hostap: Use memdup_user() rather than duplicating i... 2016-08-20 SF Markus El Rejected

Reason: A similar patch is already applied.

Applying: hostap: Use memdup_user() rather than duplicating its implementation
Using index info to reconstruct a base tree...
Falling back to patching base and 3-way merge...
Auto-merging drivers/net/wireless/intersil/hostap/hostap_ioctl.c
CONFLICT (content): Merge conflict in drivers/net/wireless/intersil/hostap/hostap_ioctl.c
Failed to merge in the changes.
Patch failed at 0001 hostap: Use memdup_user() rather than duplicating its implementation

-- 
https://patchwork.kernel.org/patch/9306999/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
