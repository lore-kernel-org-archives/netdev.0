From: Jakub Kicinski <moorray3-5tc4TXWwyLM@public.gmane.org>
Subject: Re: [PATCH v2 23/27] rt2x00: move under ralink vendor directory
Date: Thu, 19 Nov 2015 22:05:22 +0000
Message-ID: <20151119220522.24fa2733@laptop>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
	<1447857966-19560-24-git-send-email-kvalo@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1447857966-19560-24-git-send-email-kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Nov 2015 16:46:02 +0200, Kalle Valo wrote:
> Part of reorganising wireless drivers directory and Kconfig.
> 
> Signed-off-by: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>

For Ralink you could probably drop the rt2x00 directory.  RaLink Tech.
doesn't exist any more and rt2x00 contains drivers for all of their
devices.

Obviously this is just a suggestion, not a show stopper.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
