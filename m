From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2011-06-03
Date: Sat, 4 Jun 2011 16:36:17 +0200
Message-ID: <BANLkTimF3Jr4Kp7rDo1dvdBxVPepr__OZw@mail.gmail.com>
References: <20110603195254.GF2509@tuxdriver.com>
	<BANLkTimoeVDQK+zu=U+nSM_kj0a3-hh_Jg@mail.gmail.com>
	<20110604130413.GA3929@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110604130413.GA3929-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

W dniu 4 czerwca 2011 15:04 u=C5=BCytkownik John W. Linville
<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> napisa=C5=82:
> On Fri, Jun 03, 2011 at 11:24:49PM +0200, Rafa=C5=82 Mi=C5=82ecki wro=
te:
>> On Jun 3, 2011 10:03 PM, "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>=
 wrote:
>> >
>> > Dave,
>> >
>> > Here is a batch of fixes intended for 3.0 -- I guess I'll need to
>> > rename my tree eventually... :-)
>> >
>> > Included are a libertas fix to ensure proper sequence number assig=
nment
>> > on transmitted frames, an ath9k fix that propogates an earlier fix=
 to a
>> > few more places, =C2=A0a fix for a cfg80211 regression caused by s=
ome mesh
>> > code changes, a locking fix for the bluetooth l2cap code, a zd1211=
rw
>> > regression fix, a collection of small fixes for wl12xx, an iwl4965
>> > fix for a bad temperature check, an a device ID-related fix for iw=
lagn.
>> >
>> > Please let me know if there are problems!
>>
>> John, you didn't.take my fix for regression in ssb. I really want th=
is for
>> 3.0.quickly, as few ppl already had problems with machine locking on=
 boot.
>
> Yours isn't the only fix, and I had quite a few queued already. =C2=A0=
Patience.

OK, I was just afraid you missed this one :) Sorry if I meant rude.

--=20
Rafa=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
