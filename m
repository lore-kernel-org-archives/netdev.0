From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2011-04-01
Date: Fri, 01 Apr 2011 17:17:29 -0700 (PDT)
Message-ID: <20110401.171729.112600173.davem@davemloft.net>
References: <20110401141224.GA3253@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110401141224.GA3253-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Fri, 1 Apr 2011 10:12:26 -0400

> On the Bluetooth front, we have a WARNING fix related to debugobjects, a
> fix for L2CAP channel hang, a fix for an unlock without a lock, a fix to
> check for LE connections before discarding data, a fix for
> synchronization after HCI_RESET, an accounting fix for unacked frames,
> and a device ID addition.
> 
> For wireless LANs, an iwlegacy fix to prevent a possible crash during a
> firmware restart, a carl9170 fix to generate BlockAckReq if the
> transmission of an AMPDU subframe fails (i.e. an interop fix), an
> iwl3945 change to disable hw scan by default due to a number of related
> problems, a related debug message change to avoid some confusion, a fix
> for aggregation frame reordering, a cfg80211 fix to avoid
> double-unlinking a BSS entry, a trio of NULL pointer deref fixes, an
> ath9k fix to avoid a bus error during restart, a minstrel_ht fix to
> avoid a crash when no supported MCS rates are found, and some new device
> IDs for rt2x00.
> 
> Please let me know if there are problems!

Looks good, pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
