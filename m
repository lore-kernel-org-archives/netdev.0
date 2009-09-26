From: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Subject: Re: Fw: Cannot register at bugzilla (bugreport added) [ ath5k
	bugreport ]
Date: Sat, 26 Sep 2009 08:46:20 -0400
Message-ID: <20090926124620.GA5188@hash.localnet>
References: <20090925191524.7b2b228c@schatten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: hans.ullrich-LYJP0WDo+eM@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090925191524.7b2b228c@schatten>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 25, 2009 at 07:15:24PM +0200, Florian Mickler wrote:
> cc's added
> 
> could you also:
>  - tell the version of the broken kernel, 
>  - the last working kernel version, 
>  - test if it works with current kernel-snapshot from
>    http://www.kernel.org/ 

Yes, please.

> kernel-module "ath5k" gets no IP when using dhcp
> 
> Description: It is not possible, to get an IP-address by using dhcp
> with the kernel-module ath5k. It is possible, to give a fixed IP to
> that module.

It works here - I would guess the packets are getting dropped.
Do you have anything in 'dmesg' while trying to associate?

> There are already other reports of this problem in discussion forums.
> It seems, the old madwifi-driver works better with dhcp - so people say.

Can you point to such a discussion?  It's best to discuss on ath5k-devel
or linux-wireless ML so we will know about it.

-- 
Bob Copeland %% www.bobcopeland.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
