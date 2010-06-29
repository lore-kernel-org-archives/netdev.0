From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] Bluetooth: hidp: Add support for hidraw
 HIDIOCGFEATURE and HIDIOCSFEATURE
Date: Tue, 29 Jun 2010 12:07:42 +0300
Message-ID: <20100629090742.GA2716@jh-x301>
References: <1276467601-9066-1-git-send-email-alan@signal11.us>
 <20100628131437.bde782b6.ospite@studenti.unina.it>
 <20100629.001216.91341775.davem@davemloft.net>
 <alpine.LNX.2.00.1006291047560.13809@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org,
	alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, mdpoole-IZmAEv5cUt1AfugRpC6u6w@public.gmane.org,
	hadess-0MeiytkfxGOsTnJN9+BGXg@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1006291047560.13809-ztGlSCb7Y1iN3ZZ/Hiejyg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Jun 29, 2010, Jiri Kosina wrote:
> Frankly, I don't understand what exactly the current situation with 
> in-kernel bluetooth stack is anyway. 
> 
> What is the relation between what we have in net/bluetooth and the tree at 
> [1], which seems to be quite actively developed?

The difference is that the userspace part has essentially two
maintainers (me and Marcel) whereas the kernel side only has one
(Marcel). So even when Marcel is inactive I can at least take care of
the userspace side. I'd volunteer for the kernel also but I don't really
have any experience there (only 3-4 patches so far).

Johan
