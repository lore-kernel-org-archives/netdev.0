From: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC PATCH] vsprintf: Add %p*D extension for 80211 SSIDs
Date: Tue, 08 Jan 2013 10:57:30 +0800
Message-ID: <50EB8B1A.9000404@asianux.com>
References: <50E82D7D.4090107@asianux.com>  <1357396966.21156.4.camel@joe-AO722> <50EA37CE.1090901@asianux.com>  <1357528746.4940.31.camel@joe-AO722> <1357534195.21481.31.camel@joe-AO722>  (sfid-20130107_055017_668200_9F1C3EAF) <1357544828.9912.0.camel@jlt4.sipsolutions.net> <1357579362.21481.45.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1357579362.21481.45.camel@joe-AO722>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2013=E5=B9=B401=E6=9C=8808=E6=97=A5 01:22, Joe Perches =E5=86=
=99=E9=81=93:
> On Mon, 2013-01-07 at 08:47 +0100, Johannes Berg wrote:
>> > print_ssid() is used in two or
>> > three legacy drivers only, not in any modern driver, and is unlike=
ly to
>> > be used in the more modern drivers due to tracing etc.
> Swell.  It was just another way to correct those overrun
> errors Chen Gang found.
>=20

  sorry, I am not quite clear about what you said.


--=20
Chen Gang

Asianux Corporation
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
