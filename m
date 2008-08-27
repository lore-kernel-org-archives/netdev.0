From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Wed, 27 Aug 2008 15:10:34 +0200
Message-ID: <200808271510.35950.mb@bu3sch.de>
References: <20080827013009.GA15781@tuxdriver.com> <1219831828.3891.3.camel@johannes.berg> <1ba2fa240808270434y1589761xd2ff0a48c2e99033@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Marcel Holtmann" <holtmann-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1ba2fa240808270434y1589761xd2ff0a48c2e99033-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 27 August 2008, Tomas Winkler wrote:
> > should use Linux upstream as your development tree and then branch off
> > of that for the internal stabilisation trees you need for other
> > customers, rather than having some sort of internal development tree and
> > branching out Linux upstream as you appear to work.
> 
> Unfortunately fixing bugs on stable branch take precedence  of
> adjusting to new API on development branch that someone decided to do.
>  I wanted to work directly on wireless testing but it was broken over
> an over and I have only limited resources more in testing then in
> development I just had to branch out to be ready with the driver when
> HW is out. People just check the immediate impact of they fix the
> don't test for collateral damage and this is understandable an
> individual developer doesn't have lab with IBSS, BSS, AP, etc setups.

I think it would be an advantage for you to develop in wireless-testing
and use wireless-2.6 and probably additionally some internal trees as
stable trees. Like everybody else does it.

The advantage is simple: You get more people testing your code.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
