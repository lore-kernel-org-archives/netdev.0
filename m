From: Nico Schottelius <nico-linux-20111017@schottelius.org>
Subject: Re: BUG: All network processes hang (brcmsmac/wpa_supplicant)
Date: Wed, 19 Oct 2011 16:58:00 +0200
Message-ID: <20111019145800.GC1414@schottelius.org>
References: <20111019123602.GA11883@schottelius.org>
 <1319028563.8416.1.camel@edumazet-laptop>
 <20111019130749.GD11883@schottelius.org>
 <20111019142837.GA1414@schottelius.org>
 <1319035584.8416.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nico Schottelius <nico-linux-20111017@schottelius.org>,
	Arend van Spriel <arend@broadcom.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1319035584.8416.34.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet [Wed, Oct 19, 2011 at 04:46:24PM +0200]:
> Le mercredi 19 octobre 2011 =E0 16:28 +0200, Nico Schottelius a =E9cr=
it :
> > Triggered it!=20
> >=20
> > And also got the traceback!
> >=20
> > Dmesg + log attached, let me know when I can pull the fix from
> > somewhere.
> >=20
>=20
> Sorry, I cant see same messages in your dmesg, no mention of stuck
> processes (blocked for more than 120 seconds.)
>=20
> By the way, please update to latest 3.1.rc10
=20
I can rebuild Linus' tree if you want, but only use it temporarily due
to the other errors mentioned in the previous message.

If you've a tree somewhere that merges on top of Keith+Jiri,
I'd try to merge that one as well, to make the mba more usable.

Cheers,

Nico

--=20
PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0
