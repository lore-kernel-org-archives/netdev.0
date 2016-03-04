From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH RFC/RFT 1/2] ath9k: rename struct ath_txq to struct ath_hwq
Date: Fri, 04 Mar 2016 08:41:28 +0200
Message-ID: <87vb52lp7r.fsf@purkki.adurom.net>
References: <E1abeND-0007xj-00@www.xplot.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
	andrewmcgr-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, apenwarr-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
To: Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1abeND-0007xj-00-k6rWiVCi6FQBXFe83j6qeQ@public.gmane.org> (Tim Shepard's message of "Thu,
	03 Mar 2016 20:17:43 -0500")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org> writes:

> Also use hwq instead of txq to refer to it throughout ath9k/*.  This
> is prep work for using mac80211's new intermediate queues, which are
> called txq, and it would be too confusing if both are called txq.

You should add Signed-off-by to both patches in case someone else wants
to work with these.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
