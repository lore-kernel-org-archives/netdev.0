From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] iwlegacy: change IWL_WARN to IWL_DEBUG_HT in
 iwl4965_tx_agg_start
Date: Mon, 29 Aug 2011 16:00:36 +0200
Message-ID: <20110829140032.GA1573@redhat.com>
References: <1314537977-20097-1-git-send-email-Gregory.Dietsche@cuw.edu>
 <20110829122013.GA3597@redhat.com>
 <4E5B9533.6000109@cuw.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg Dietsche <gregory.dietsche-5+R7UueiBCQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E5B9533.6000109-5+R7UueiBCQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Greg

On Mon, Aug 29, 2011 at 08:33:39AM -0500, Greg Dietsche wrote:
> On 08/29/2011 07:20 AM, Stanislaw Gruszka wrote:
> >On Sun, Aug 28, 2011 at 08:26:16AM -0500, Greg Dietsche wrote:
> >>This message should be a debug message and not a warning. So
> >>change it from IWL_WARN to IWL_DEBUG_HT.
> >I'm currently doing massive iwlegacy driver cleanup. Would be easier
> >for me to apply these patches on top of my changes instead of rebase
> >my patches. I will queue these two patches and post them together with
> >my pending patches.
> >
> That sounds good to me. I have the 4065 card in my laptop and want
> to learn how it works. If you want someone to test your changes, I'm
> willing.
> 
> I have six other patches that are trivial in nature for the iwlegacy
> driver. One of those also applies to the iwlagn driver, so seven
> patches in total. They remove some null checks that aren't necessary
> and also cleanup a few unused variables. There are two patches in
> the set that I'm not 100% sure about. They remove null checks and I
> haven't been able to prove to myself that they are correct. However,
> if they aren't correct, then there are some null checks in other
> places that need to be added....
> 
> Anyway, I can hold off on these until you've done your cleanup and
> see what still applies,

That would be great.

> or if you have a tree someplace, I'd be
> happy to rebase them for you.

I do not have publicly available tree. I'll probably try to get
one on git.kernel.org. I will let you know.

Thanks,
Stanislaw
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
