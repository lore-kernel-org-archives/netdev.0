From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: [PATCH 0/2] Bluetooth: Fix regressions for 3.0
Date: Sat, 16 Jul 2011 01:30:19 -0300
Message-ID: <1310790621-28510-1-git-send-email-padovan@profusion.mobi>
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>

Gustavo F. Padovan (1):
  Bluetooth: Fix regression in L2CAP connection procedure

Ilia Kolomisnky (1):
  Bluetooth: Fix crash with incoming L2CAP connections

 net/bluetooth/l2cap_core.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

-- 
1.7.6
