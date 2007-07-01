From: Joerg Mayer <jmayer-2TuS4uRBb1yzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] zd1211rw-mac80211: basic regulatory domain support
Date: Sun, 1 Jul 2007 22:32:38 +0200
Message-ID: <20070701203238.GE8218@thot.informatik.uni-kl.de>
References: <20070701163907.39B6B7B409F@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070701163907.39B6B7B409F-k/4jFdqg8LLlyo9zxV8I99HuzzzSOjJt@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 01, 2007 at 05:39:06PM +0100, Daniel Drake wrote:
> This patch causes zd1211rw-mac80211 to interpret the regdomain in the
> EEPROM and restrict the channels accordingly, like the softmac driver does.

The patch only addresses the allowed channels but not the allowed
maximum power levels. Is this intentional?
I've only looked at the patch, so maybe this is handled elsewhere.


 ciao
       Joerg
--
Joerg Mayer                                           <jmayer-2TuS4uRBb1yzQB+pC5nmwQ@public.gmane.org>
We are stuck with technology when what we really want is just stuff that
works. Some say that should read Microsoft instead of technology.
