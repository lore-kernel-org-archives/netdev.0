From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] checkpatch: Add some --strict coding style checks
Date: Wed, 22 Feb 2012 09:35:14 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E77@saturn3.aculab.com>
References: <804857E1F29AAC47BF68C404FC60A18429B3EE@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrei.emeltchenko.news-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Allan, Bruce W" <bruce.w.allan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Joe Perches" <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Andy Whitcroft" <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	"Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <804857E1F29AAC47BF68C404FC60A18429B3EE-P5GAC/sN6hlcIJlls4ac1rfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 
> 	if (!(func_a(x) &&
> 		func_b(y)))
> 		baz();

Gah - that is horrid for the 'preferred style'.
A quick glance at the code puts both the func_b()
and baz() calls as inside the if.

	David


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
