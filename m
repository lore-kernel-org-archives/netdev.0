From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 1/7][MAC8021]: Fix one more call to synchronize_rcu in
	atomic context.
Date: Fri, 16 May 2008 11:16:20 -0400
Message-ID: <20080516151620.GC6510@tuxdriver.com>
References: <4821CE54.9000401@openvz.org> <482D6A80.6030804@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <482D6A80.6030804-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 16, 2008 at 03:05:36PM +0400, Pavel Emelyanov wrote:

> Sorry for bothering you, I guess that you're very busy now, 
> but what are you plans about this set?
> 
> After I saw my first set included in some wireless git update,
> I thought this one would be in some of the next ones (since
> this set fixes some bugs in mesh tables), and started waiting.
> 
> Here's a new wireless git update and this set is still not in.
> Shall I resubmit one?

Pavel,

I still have your patchset.  I'm still working on clearing my
backlog, as well as waiting for some fixes to make the round-trip
net-2.6->linux-2.6->net-next-2.6.  The combination of that and the
fact that your patch hit locking and "the usual suspects" had not
yet commented on it made me decide to wait until the next round.

If you are desperate to see them sooner, I could probably put them
in the -testing tree early?  Let me know if you would like that.

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
