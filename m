From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC PATCH] vsprintf: Add %p*D extension for 80211 SSIDs
Date: Sun, 06 Jan 2013 22:37:50 -0800
Message-ID: <1357540670.21481.38.camel@joe-AO722>
References: <50E82D7D.4090107@asianux.com>
	 <1357396966.21156.4.camel@joe-AO722> <50EA37CE.1090901@asianux.com>
	 <1357528746.4940.31.camel@joe-AO722> <1357534195.21481.31.camel@joe-AO722>
	 <50EA6612.6010506@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50EA6612.6010506-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-01-07 at 14:07 +0800, Chen Gang wrote:
> =E4=BA=8E 2013=E5=B9=B401=E6=9C=8807=E6=97=A5 12:49, Joe Perches =E5=86=
=99=E9=81=93:
> > On Sun, 2013-01-06 at 19:19 -0800, Joe Perches wrote:
> >> Maybe these days this should be another vsprintf %p extension
> >> like %pM when the DECLARE_MAC_BUF/print_mac uses were converted.
> >>
> >> (or maybe extend %ph for ssids with %*phs, length, array)
> >=20
>   excuse me:
>     I do not quite know how to reply the [RFC PATCH].
>     it would be better if you can tell me how to do for [RFC PATCH], =
thanks.

You did fine except you unnecessarily quoted the entire original email.
Remember to trim your replies please.  _lots_ of people read these
mailing lists and unnecessary quoting wastes all of their times.

>   at least for me:
>     although it is good idea to add common, widely used features in p=
ublic tools function.

It's akin to most of the minor uuid/bluetooth mac, etc codes
in vsprintf I've added.

cheers, Joe

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
