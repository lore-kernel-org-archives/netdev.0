From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Sat, 01 Mar 2008 14:59:58 -0800 (PST)
Message-ID: <20080301.145958.33975454.davem@davemloft.net>
References: <20080229191058.GD3234@tuxdriver.com>
	<20080229214240.GH3234@tuxdriver.com>
	<20080301130133.GA14250@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	gordonfarquharson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080301130133.GA14250-QabhHTsIXMSnlFQ6Q1D1Y0B+6BGkLq7r@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Date: Sat, 1 Mar 2008 14:01:33 +0100

> And that for shaving 6 bytes of a structure..

No, it's for not breaking existing userland binaries out there.  We
released 2.6.24 with the existing struct layout, we have to live with
it.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
