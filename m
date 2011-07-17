From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 0/2] Bluetooth: Fix regressions for 3.0
Date: Sun, 17 Jul 2011 12:46:31 -0400
Message-ID: <20110717164631.GA18545@tuxdriver.com>
References: <1310790621-28510-1-git-send-email-padovan@profusion.mobi>
 <20110716.101518.1007939482226184514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110716.101518.1007939482226184514.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 16, 2011 at 10:15:18AM -0700, David Miller wrote:
> From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
> Date: Sat, 16 Jul 2011 01:30:19 -0300
> 
> > From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
> > 
> > Gustavo F. Padovan (1):
> >   Bluetooth: Fix regression in L2CAP connection procedure
> > 
> > Ilia Kolomisnky (1):
> >   Bluetooth: Fix crash with incoming L2CAP connections
> > 
> >  net/bluetooth/l2cap_core.c |    9 +++++----
> >  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> John I'm going to apply these directly so I can get them to
> Linus in time for 3.0-final.
> 
> Thanks Gustavo.

Yup, looks great -- thanks!

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
