From: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] mac80211: ath9k: Use RCU protection calling ieee80211_get_tx_rates
Date: Wed, 12 Jun 2013 09:37:18 +0300
Message-ID: <87ehc73kdd.fsf@purkki.adurom.net>
References: <20130609225120.GA2789@gmail.com>
	<20130610042959.GA1902@gmail.com>
	<1370950926.8356.14.camel@jlt4.sipsolutions.net>
	<20130611171304.GA2189@gmail.com>
	<1370980523.8356.70.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Calvin Owens <jcalvinowens-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1370980523.8356.70.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org> (Johannes Berg's
	message of "Tue, 11 Jun 2013 21:55:23 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> writes:

> Now the subject should no longer say "mac80211:" :)

It did have a change to mac80211.h as well, but IMHO that should be in a
separate patch.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
