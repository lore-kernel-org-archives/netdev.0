From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless 2013-02-01
Date: Fri, 01 Feb 2013 14:50:52 -0500 (EST)
Message-ID: <20130201.145052.1736779736271048954.davem@davemloft.net>
References: <20130201191745.GA29418@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130201191745.GA29418-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Fri, 1 Feb 2013 14:17:45 -0500

> I'm sorry you got hit by the flu!  Hopefully you are fully recovered
> by now? :-)

I'm recovered enough to review everyone's buggy patches :-)

> This is a small batch of fixes intended for the 3.8 stream...
>=20
> There are two pulls from Johannes.  Regarding mac80211, Johannes says=
:
>=20
> "One fix from Dan for a possible memory overrun."
>=20
> Regarding iwlwifi,  Johannes says:
>=20
> "I have one fix from Emmanuel reverting a previous fix that caused
> more trouble than it's worth."
>=20
> Along with those:
>=20
> Arend van Spriel fixes a fatal error in brcsmac related to tx status =
processing.
>=20
> Bing Zhao corrects a problem where mwifiex would fail to complete a s=
can
> in the event of an IE processing error.
>=20
> Larry Finger fixes a thinko in rtlwifi in which the wrong skb variabl=
e
> was being used in some cases.
>=20
> Rafa=A9=A9 Mi=A9=A9ecki fixes a thinko in an ID check in the bcma fla=
sh code.

Pulled, thanks John.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
