From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Thu, 29 Oct 2009 15:39:14 +0100
Message-ID: <200910291539.16476.mb@bu3sch.de>
References: <200910291435.54203.bzolnier@gmail.com> <200910291514.40318.bzolnier@gmail.com> <20091029.072101.109209962.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091029.072101.109209962.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 29 October 2009 15:21:01 David Miller wrote:
> The issue is that John disagrees with you can you can't handle
> that.
> 
> So instead of continuing to discuss things with him and the
> other wireless folks, you want me to just overreach everybody
> and revert someone else's work.

In the end this results in the driver maintainer being forced to maintain
code and handle bugreports for code that he disagrees with in the first place.
This is unacceptable and has to be resolved in some way.
If it's not possible to get it reverted through John (for whatever reason),
you're in charge to help the actual code maintainer out.

> I'm not going to do that sorry, learn how to work with the
> wireless people instead.

This is not the problem.
The problem is that stuff is merged without ack from the maintainer
and it's virtually impossible to get the stuff reverted. The only real
way for the maintainer to resolve this is 1) live with it or 2) fix it.
And that's bad, because it completely invalidates his priority queue.

Just like you must not bypass John, the driver maintainers must not be bypassed, too.
The quality control does _only_ work if nobody in the chain is bypassed.
But in this situation the quality control did already fail and it should be
tried hard to resolve (=revert) the situation instead of pointing at John.

-- 
Greetings, Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
