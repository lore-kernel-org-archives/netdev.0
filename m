From: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Subject: Re: [Resend][PATCH] Wireless / ath5k: Simplify suspend and resume
	callbacks
Date: Sat, 21 Nov 2009 22:18:46 -0500
Message-ID: <20091122031846.GA6215@hash.localnet>
References: <200911212344.24170.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	pm list <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200911212344.24170.rjw-KKrjLPT3xs0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 21, 2009 at 11:44:24PM +0100, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
> Subject: Wireless / ath5k: Simplify suspend and resume callbacks
> 
> Simplify the suspend and resume callbacks of ath5k by converting the
> driver to struct dev_pm_ops and allowing the PCI PM core to do the
> PCI-specific suspend/resume handling.
> 
> Tested with Atheros Communications Inc. AR2413 802.11bg NIC (rev 01)
> D-Link CardBus.adapter.
> 
> Signed-off-by: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>

Acked-by: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>

Thanks for the resend, sorry it got lost in the shuffle.

-- 
Bob Copeland %% www.bobcopeland.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
