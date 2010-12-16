From: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Subject: Re: iwl rfkill suddenly dropped to hard block
Date: Thu, 16 Dec 2010 14:57:18 +0300
Message-ID: <20101216115717.GA15075@ioremap.net>
References: <20101215195651.GA18545@ioremap.net>
 <20101215201126.GG2377@tuxdriver.com>
 <20101216032247.GA7345@ioremap.net>
 <4D099444.5040703@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D099444.5040703-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 15, 2010 at 10:23:32PM -0600, Larry Finger (Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org) wrote:
> >I would imagine this is just related to some dellish crap, but I saw a
> >number of exactly the same cases in the web including linux-kernel mail
> >lists in the past and also without 'slider on the back' case.
> 
> I doubt that it is Dell related, if that is what "dellish" means.
> 
> I have had some success in clearing this problem by unloading and
> reloading the wireless driver. I had the problem on one box that has
> no rfkill switch and an 802.11b card that uses b43legacy.

I tried that as well as disabling and enabling wifi in bios (or is it
newr loader), but without success. I called this 'dellish' crap
because of the hell list of problems I had with this laptop and i915
video chipset in it. Apparently brother model e4200 does not have them
at all.

-- 
	Evgeniy Polyakov
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
