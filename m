From: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 3.6-rc3] wlcore: Declare MODULE_FIRMWARE usage
Date: Wed, 29 Aug 2012 21:57:48 +0300
Message-ID: <1346266668.3935.23.camel@cumari.coelho.fi>
References: <1346251689-37023-1-git-send-email-tim.gardner@canonical.com>
	 <1346259706.3935.2.camel@cumari.coelho.fi> <503E4DBB.4030606@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Eliad Peller <eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	Arik Nemtsov <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>, Eyal Shapira <eyal-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <503E4DBB.4030606-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-08-29 at 11:13 -0600, Tim Gardner wrote:
> On 08/29/2012 11:01 AM, Luciano Coelho wrote:
> > On Wed, 2012-08-29 at 08:48 -0600, Tim Gardner wrote:
> >> Cc: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
> >> Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> >> Cc: Eliad Peller <eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>
> >> Cc: Arik Nemtsov <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>
> >> Cc: Eyal Shapira <eyal-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>
> >> Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >> Signed-off-by: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> >> ---
> > 
> > Please add a proper commit message.  And there's no need to put all
> > these people in Cc: in the commit log.  CC'ing when sending the patch is
> > enough (even though for such small patch, the linux-wireless mailing
> > list and myself is enough).
> > 
> > --
> > Luca.
> > 
> 
> What more would you like covered in the commit message that isn't
> obvious from the subject?

It's obvious from the subject, indeed.  But commits with no descriptions
are ugly.  Add something, for example a small "why" would be nice.


> The Cc list comes from scripts/get_maintainers.pl as suggested by
> Documentation/SubmittingPatches: "5) Select e-mail destination."

Yeah, that's correct, but it doesn't mean you should put them as Cc:
tags in the commit log.  CCing when *sending* the email only is enough.
Most people won't really care for the entire lifetime of this patch.
And, come on, the Cc tags take more space than the actual patch.

--
Luca.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
