From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: All network processes hang (brcmsmac/wpa_supplicant)
Date: Wed, 19 Oct 2011 16:46:24 +0200
Message-ID: <1319035584.8416.34.camel@edumazet-laptop>
References: <20111019123602.GA11883@schottelius.org>
	 <1319028563.8416.1.camel@edumazet-laptop>
	 <20111019130749.GD11883@schottelius.org>
	 <20111019142837.GA1414@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend@broadcom.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Nico Schottelius <nico-linux-20111017@schottelius.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111019142837.GA1414@schottelius.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 19 octobre 2011 =C3=A0 16:28 +0200, Nico Schottelius a =C3=A9=
crit :
> Triggered it!=20
>=20
> And also got the traceback!
>=20
> Dmesg + log attached, let me know when I can pull the fix from
> somewhere.
>=20

Sorry, I cant see same messages in your dmesg, no mention of stuck
processes (blocked for more than 120 seconds.)

By the way, please update to latest 3.1.rc10
