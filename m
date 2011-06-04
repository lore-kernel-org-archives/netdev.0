From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-2.6 2011-06-03
Date: Sat, 4 Jun 2011 09:04:14 -0400
Message-ID: <20110604130413.GA3929@tuxdriver.com>
References: <20110603195254.GF2509@tuxdriver.com>
 <BANLkTimoeVDQK+zu=U+nSM_kj0a3-hh_Jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTimoeVDQK+zu=U+nSM_kj0a3-hh_Jg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 03, 2011 at 11:24:49PM +0200, Rafa=C5=82 Mi=C5=82ecki wrote=
:
> On Jun 3, 2011 10:03 PM, "John W. Linville" <linville@tuxdriver.com> =
wrote:
> >
> > Dave,
> >
> > Here is a batch of fixes intended for 3.0 -- I guess I'll need to
> > rename my tree eventually... :-)
> >
> > Included are a libertas fix to ensure proper sequence number assign=
ment
> > on transmitted frames, an ath9k fix that propogates an earlier fix =
to a
> > few more places,  a fix for a cfg80211 regression caused by some me=
sh
> > code changes, a locking fix for the bluetooth l2cap code, a zd1211r=
w
> > regression fix, a collection of small fixes for wl12xx, an iwl4965
> > fix for a bad temperature check, an a device ID-related fix for iwl=
agn.
> >
> > Please let me know if there are problems!
>=20
> John, you didn't.take my fix for regression in ssb. I really want thi=
s for
> 3.0.quickly, as few ppl already had problems with machine locking on =
boot.

Yours isn't the only fix, and I had quite a few queued already.  Patien=
ce.

--=20
John W. Linville =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
Someday the world will need a hero, and you
linville@tuxdriver.com =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0might be all we have. =C2=A0Be ready.
