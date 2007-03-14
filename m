From: Jouni Malinen <j@w1.fi>
Subject: Re: [HOSTAP] Make debug a run-time option
Date: Wed, 14 Mar 2007 22:05:38 +0000
Message-ID: <20070314220538.GA23642@hostap.isc.org>
References: <20070314160356.GA16337@athena.road.mcmartin.ca> <20070314171742.GA20779@hostap.isc.org> <20070314194800.GF3372@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kyle McMartin <kyle-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hostap-I1pBevtZXGcAvxtiuMwx3w@public.gmane.org, j@w1.fi
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070314194800.GF3372-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 14, 2007 at 03:48:00PM -0400, John W. Linville wrote:

> What about a combined approach?  The existing compile-time option
> could remain while runtime restrictions could be added for when the
> debug stuff is compiled into the driver?

I would be perfectly fine with doing that assuming the default behavior
is not changed with this patch (i.e., debugging would be enabled by
default). I would consider changing the default setting a separate issue
and for that, it might be more worthwhile approach to identify the debug
messages that are undesired by default than to disable everything.

-- 
Jouni Malinen                                            PGP id EFC895FA
