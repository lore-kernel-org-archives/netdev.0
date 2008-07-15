From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Linux Wireless Mini-Summit -- Ottawa -- July 22, 2008
Date: Tue, 15 Jul 2008 14:15:31 -0400
Message-ID: <1216145731.13411.25.camel@localhost.localdomain>
References: <20080709190915.GA8238@tuxdriver.com>
	 <247d6d340807140805gfb6523en74384f6f47469d79@mail.gmail.com>
	 <20080715174246.GA3117@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Guy Cohen <guy-7H3QRnBdods@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080715174246.GA3117-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2008-07-15 at 13:42 -0400, John W. Linville wrote:
> On Mon, Jul 14, 2008 at 06:05:13PM +0300, Guy Cohen wrote:
> > I think that probably the most burning topics were a little diminished
> > in our agenda, and should be put higher:
> > - cfg80211/nl80211 - much of the current wext begins to fall behind
> > the emerging capabilities of the mac80211 and moreover - from future
> > abilities and needs of future fullmac devices. The functionality and
> > ABI to userspace must be finalized as soon as possible. The status of
> > this is very unclear and should be treated more thoroughly, and it
> > seems it can't be shared with 5 other topics in less than 2 hours.
> 
> FWIW, I listed this one first under Future Work.
> 
> > - fullmac support - seems to be very relevant in the next couple of
> > years with the integration of wifi into low power devices running
> > linux.
> 
> Not sure exactly what you mean with this one.  Are you talking about
> the lib80211 line item?  Or enhancements to the mac80211 component
> to support full(er) MAC designs?

I hope just lib80211.  We shouldn't be extending mac80211 to fullmac or
quasi-fullmac parts.  But we can certainly share a lot of stuff.
lib80211 is where I see any additional fullmac effort going.

Dan

> > I think that these two topics should take precedence over other topics
> > that although important consume more time in the agenda, and are
> > currently less likely to have impact on the average users such as 11s
> > and 11w.
> > 
> > it would be good if these topics will get substantial time slot in the agenda.
> 
> There are lots of items listed, and I'm not sure we will cover all
> of them.  If there are any that you would like to suggest be dropped
> completely then please do so.
> 
> That said, I don't think we have enough time for real working sessions
> on Tuesday.  I think it would be better just to touch on a variety
> of topics that can benefit from some face-to-face discussions.
> From that perspective, I think some status reports and some brief
> proposals are most appropriate.
> 
> I'll post a revised (mostly just augmented) agenda proposal today.
> 
> John

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
