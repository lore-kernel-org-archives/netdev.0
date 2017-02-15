From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: orinoco: Use net_device_stats from struct net_device
Date: Wed, 15 Feb 2017 09:13:55 +0000 (UTC)
Message-ID: <20170215091355.096DB60C53@smtp.codeaurora.org>
References: <20170210130313.27821-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170210130313.27821-1-tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org> wrote:
> Instead of using a private copy of struct net_device_stats in
> struct orinoco_private, use stats from struct net_device. Also remove
> the now unnecessary .ndo_get_stats function.
> 
> Signed-off-by: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>

Patch applied to wireless-drivers-next.git, thanks.

3a6282045b22 orinoco: Use net_device_stats from struct net_device

-- 
https://patchwork.kernel.org/patch/9566717/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
