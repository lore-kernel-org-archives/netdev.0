From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Thu, 28 Feb 2008 16:15:24 -0800 (PST)
Message-ID: <20080228.161524.183616961.davem@davemloft.net>
References: <97a0a9ac0802281321h6f302865j38a55c6f761dc14b@mail.gmail.com>
	<20080228.133008.228590007.davem@davemloft.net>
	<97a0a9ac0802281556q2d65ea0fu9f59e02b989fffcf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: gordonfarquharson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <97a0a9ac0802281556q2d65ea0fu9f59e02b989fffcf-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Gordon Farquharson" <gordonfarquharson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 28 Feb 2008 16:56:52 -0700

> On Thu, Feb 28, 2008 at 2:30 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> >  Feel free to push that via Andrew or someone else, but that turd isn't
> >  going in by my tree because to me it's clearly the wrong thing to do.
> 
> Would you support the idea, put forward by Matthieu Castet on LKML, to
> change the test in file2alias such that it issues a warning as opposed
> to an error?

I'm ambivalent, the only constraint is that you cannot
change the layout and alignment of this struct since it
already appeared in 2.6.24 and therefore tools have
been compiled against the existing way it is defined.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
