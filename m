From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: ath6kl: Use net_device_stats from struct net_device
Date: Tue, 14 Feb 2017 09:57:54 -0800
Message-ID: <5bff5d456de54c548b0b9e8e25f3f825@eusanexr01a.eu.qualcomm.com>
References: <20170209112117.23994-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170209112117.23994-1-tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org> wrote:
> Instead of using a private copy of struct net_device_stats in struct
> ath6kl_vif, use stats from struct net_device. Also remove the now
> unnecessary .ndo_get_stats function.
> 
> Signed-off-by: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>

Patch applied to ath-next branch of ath.git, thanks.

1235a3b66cbf ath6kl: Use net_device_stats from struct net_device

-- 
https://patchwork.kernel.org/patch/9564413/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
