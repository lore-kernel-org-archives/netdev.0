From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 0/3] ath6kl: neatening
Date: Sun, 17 Jul 2011 11:43:41 -0700
Message-ID: <cover.1310927985.git.joe@perches.com>
Cc: devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org, error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe Perches (3):
  ath6kl: Add missing newlines and coalesce messages
  ath6kl: Remove __func__ uses from ath6kl_err
  ath6kl: cfg80211: Add and use ath6kl_cfg80211_ready helper

 drivers/net/wireless/ath/ath6kl/bmi.c      |    2 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c |  230 ++++++++-------------------
 drivers/net/wireless/ath/ath6kl/debug.c    |    2 +-
 drivers/net/wireless/ath/ath6kl/htc.c      |   15 +-
 drivers/net/wireless/ath/ath6kl/htc_hif.c  |    3 +-
 drivers/net/wireless/ath/ath6kl/init.c     |   79 ++++------
 drivers/net/wireless/ath/ath6kl/main.c     |   16 +-
 drivers/net/wireless/ath/ath6kl/txrx.c     |   53 +++----
 drivers/net/wireless/ath/ath6kl/wmi.c      |   29 ++--
 9 files changed, 155 insertions(+), 274 deletions(-)

-- 
1.7.6.131.g99019

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
