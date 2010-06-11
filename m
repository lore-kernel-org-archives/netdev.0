From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] [ath5k][leds] Ability to disable leds
 support. If leds support enabled do not force mac802.11 leds layer
 selection.
Date: Fri, 11 Jun 2010 22:29:23 +0200
Message-ID: <1276288163.3918.1.camel@jlt3.sipsolutions.net>
References: <4c0f4326.0a41df0a.7bde.ffffeef2@mx.google.com>
	<AANLkTilrYYHjcMEhhrP7zjcLoo-TNczozxJSNRkDvSZy@mail.gmail.com>
	<AANLkTimXqdkQxv_Y1JaleTTWNsDIQHQaPn8HR7efOupb@mail.gmail.com>
	<1276286993.3918.0.camel@jlt3.sipsolutions.net>
	<AANLkTim90VBfWjp2YPYeYN6ImjIyZzcJ_XnpT5cdgCt4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>, GeunSik Lim <geunsik.lim-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Keng-Yu Lin <keng-yu.lin-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Greg-juf53994utBLZpfksSYvnA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kalle-juf53994utBLZpfksSYvnA@public.gmane.org,
	Shahar Or <shahar-ThuA2tnqEQ612v9G2T7xgg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Luca Verdesca <magooz-JapBdFJSX0s@public.gmane.org>
To: Dmytro Milinevskyy <milinevskyy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
In-Reply-To: <AANLkTim90VBfWjp2YPYeYN6ImjIyZzcJ_XnpT5cdgCt4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ath5k.org/pipermail/ath5k-devel>
List-Post: <mailto:ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
List-Help: <mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=subscribe>
Sender: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
Errors-To: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-06-11 at 23:26 +0300, Dmytro Milinevskyy wrote:
> Generic LED class is not disabled so it's possible to control leds in sysfs.

But if you turn off ATH5K_LEDS??

johannes
