From: "Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH] net/wireless: use module_pci_driver
Date: Fri, 13 Apr 2012 19:48:36 -0700
Message-ID: <CAB=NE6UgiZ6qqJ2W-Pb-g-BMv71-kYSLzJxbyV-XDEzNkCeffQ@mail.gmail.com>
References: <1334371116.17649.1.camel@phoenix>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Simon Kelley <simon-xn1N/tgparsycpQjotevgVpr/1R2p/CL@public.gmane.org>,
	Jouni Malinen <j@w1.fi>,
	Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
	Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Axel Lin <axel.lin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334371116.17649.1.camel@phoenix>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 13, 2012 at 7:38 PM, Axel Lin <axel.lin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> module_pci_driver

Neat, any chance you can you send me a respective patch to add
module_pci_driver() to compat so that when we backport all this is
done automatically?

git://github.com/mcgrof/compat.git

 Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
