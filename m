From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/1] Bluetooth: hidp: Add support for hidraw
 HIDIOCGFEATURE and HIDIOCSFEATURE
Date: Tue, 29 Jun 2010 00:12:16 -0700 (PDT)
Message-ID: <20100629.001216.91341775.davem@davemloft.net>
References: <1276467601-9066-1-git-send-email-alan@signal11.us>
	<20100628131437.bde782b6.ospite@studenti.unina.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, jkosina-AlSwsSmVLrQ@public.gmane.org,
	mdpoole-IZmAEv5cUt1AfugRpC6u6w@public.gmane.org, hadess-0MeiytkfxGOsTnJN9+BGXg@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100628131437.bde782b6.ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Antonio Ospite <ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org>
Date: Mon, 28 Jun 2010 13:14:37 +0200

> On Sun, 13 Jun 2010 18:20:01 -0400
> Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org> wrote:
> 
>> This patch adds support or getting and setting feature reports for bluetooth
>> HID devices from HIDRAW.
>> 
>> Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
>> ---
> 
> Ping.

We effectively don't have a bluetooth maintainer at the current point
in time.  I've tried to let patches sit for a while hoping the listed
maintainer would do something, at least occaisionally, but that simply
isn't happening.

So I'll just pick patches up directly as I find time to review them,
but I have to warn that for me it's going to be done in a very low
priority way because I really don't find bluetooth all that exciting. :-)
