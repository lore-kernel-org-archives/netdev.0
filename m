From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/2] Bluetooth: Fix regressions for 3.0
Date: Sat, 16 Jul 2011 10:15:18 -0700 (PDT)
Message-ID: <20110716.101518.1007939482226184514.davem@davemloft.net>
References: <1310790621-28510-1-git-send-email-padovan@profusion.mobi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1310790621-28510-1-git-send-email-padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Date: Sat, 16 Jul 2011 01:30:19 -0300

> From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
> 
> Gustavo F. Padovan (1):
>   Bluetooth: Fix regression in L2CAP connection procedure
> 
> Ilia Kolomisnky (1):
>   Bluetooth: Fix crash with incoming L2CAP connections
> 
>  net/bluetooth/l2cap_core.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)

John I'm going to apply these directly so I can get them to
Linus in time for 3.0-final.

Thanks Gustavo.
