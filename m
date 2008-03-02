From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Sun, 2 Mar 2008 21:25:15 +0100
Message-ID: <200803022125.15933.mb@bu3sch.de>
References: <20080228014125.GI3078@tuxdriver.com> <20080302115828.GA15820@uranus.ravnborg.org> <97a0a9ac0803021200v117379b6x1c4bc0f8ae580040@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Sam Ravnborg" <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: "Gordon Farquharson" <gordonfarquharson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <97a0a9ac0803021200v117379b6x1c4bc0f8ae580040-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 02 March 2008 21:00:23 Gordon Farquharson wrote:
> Hi Sam
> 
> On Sun, Mar 2, 2008 at 4:58 AM, Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org> wrote:
> 
> >  Find below a patch that detect when we do a cross build and thus ignore
> >  the check.
> 
> Works for me.
> 
> Tested-by: Gordon Farquharson <gordonfarquharson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

The patch looks good. I suggest Andrew pull it for some time into
the -mm tree and then pushes it forward to Linus for 2.6.25.

You can add an Acked-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
although I can not runtime test it here.

-- 
Greetings Michael.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
