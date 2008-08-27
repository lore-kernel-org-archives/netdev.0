From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Wed, 27 Aug 2008 03:32:37 -0700 (PDT)
Message-ID: <20080827.033237.236091327.davem@davemloft.net>
References: <20080827.014041.230100807.davem@davemloft.net>
	<1219835410.5359.24.camel@californication>
	<1ba2fa240808270305m7f505efak9fd0d36d5db09a1e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: holtmann-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1ba2fa240808270305m7f505efak9fd0d36d5db09a1e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 27 Aug 2008 13:05:23 +0300

> There is a central problem here, since I cannot really adjust driver
> development progress from obvious reason with Linux merging window.

Indeed, that's exactly what your core problem is.

You think it's OK to contaminate upstream just because of the
way you have choosen to maintain your driver.

Well guess what, it's not OK to do that, and it's absolutely not our
problem that you choose to do your development in the most anti-social
way possible wrt. upstream.

Anyways, keep defending yourself.

If you persist, I can certainly make things _really_ easy, such that
if there isn't a regression list entry for the bug you are fixing and
it isn't mentioned explicitly in your commit message, I simply will
refuse to take your changes outside of the merge window.

It's that simple.

Would you like things to work that way, where I'm a hard ass, or would
you like to stop defending yourself endlessly, and instead start to be
reasonable?

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
