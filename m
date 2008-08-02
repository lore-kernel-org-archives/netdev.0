From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-01
Date: Fri, 1 Aug 2008 23:29:46 -0400
Message-ID: <20080802032946.GA29921@tuxdriver.com>
References: <20080801205830.GA10071@tuxdriver.com> <1ba2fa240808011443u1a5553fpfca046f047773217@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1ba2fa240808011443u1a5553fpfca046f047773217-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 02, 2008 at 12:43:32AM +0300, Tomas Winkler wrote:
> On Fri, Aug 1, 2008 at 11:58 PM, John W. Linville
> <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> > Dave,
> >
> > Another big batch of wireless fixes for 2.6.27.  The ath5k series is
> > more than fixes, but I included it because it enables new ath5k
> > hardware.  (The ath5k.h changes in particular are documentation cleanups
> > for registers based on info gleaned from the newly posted ath9k driver.)
> > The others patches are fixes, some more obvious than others. :-)
> >
> > Let me know if there are any problems!
> 
> All the iwlwifi patches should go up otherwise the support for 5000 HW
> will be incomplete.

Then they should have been posted before 2.6.26 was released...

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
