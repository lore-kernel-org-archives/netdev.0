From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/5 v4] nfc: Fix portid type in urelease_work
Date: Mon, 13 Apr 2015 16:35:35 -0400 (EDT)
Message-ID: <20150413.163535.158292839039038938.davem@davemloft.net>
References: <1428879159-19237-1-git-send-email-richard@nod.at>
	<1428879159-19237-2-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org, lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
	kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: richard-/L3Ra7n9ekc@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1428879159-19237-2-git-send-email-richard-/L3Ra7n9ekc@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Date: Mon, 13 Apr 2015 00:52:36 +0200

> portid is an unsigned integer. Fix urelease_work to
> match all other portid user in the kernel.
> 
> Signed-off-by: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
