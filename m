From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v4] net: sunrpc: svcsock: fix NULL-pointer exception
Date: Thu, 24 Aug 2017 18:13:01 -0400
Message-ID: <20170824221301.GA26099@fieldses.org>
References: <1503305779-6064-1-git-send-email-vlomovts@redhat.com>
 <1503314587-15420-1-git-send-email-vlomovts@redhat.com>
 <20170823102403.GF1443@dhcp187-32.khw.lab.eng.bos.redhat.com>
 <1503484422.5294.0.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Lomovtsev <vlomovts-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1503484422.5294.0.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 23, 2017 at 06:33:42AM -0400, Jeff Layton wrote:
> I think this one looks fine. Bruce, do you mind picking this one up? It
> might also be reasonable for stable...

Yep, thanks to you both, I'll plan to send a pull request tonight or
tomorrow.

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
