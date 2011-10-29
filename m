From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: >Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Sat, 29 Oct 2011 17:43:04 +0200
Message-ID: <1319902984.2586.35.camel@edumazet-laptop>
References: <1319764761.23112.14.camel@edumazet-laptop>
	 <20111028012521.GF25795@one.firstfloor.org>
	 <CA+55aFy9oJSK99K=brRzSfSnLocO=PuS7yuKkAcw3t5hATJrfw@mail.gmail.com>
	 <1319766293.6759.17.camel@deadeye>
	 <1319770376.23112.58.camel@edumazet-laptop>
	 <1319772566.6759.27.camel@deadeye>
	 <1319777025.23112.67.camel@edumazet-laptop>
	 <CA+55aFzHf563auNYdNeJnsbbry1OUfkepkiVHt7Fy-bG64Fruw@mail.gmail.com>
	 <1319803781.23112.113.camel@edumazet-laptop>
	 <CA+55aFxzgc5pC1p6J8YADNDwmAjUYNRKLvir6OQMueWqUXOaEQ@mail.gmail.com>
	 <CA+55aFxy6VSBbikFrfXwUPOafihR+MOdi+yKSp_6qz7_Vax_YA@mail.gmail.com>
	 <1319813252.23112.122.camel@edumazet-laptop>
	 <CA+55aFxvcvUopBc-Q6Fp87asTuBohev8Xdm67jcKfy4Z4_BZRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxvcvUopBc-Q6Fp87asTuBohev8Xdm67jcKfy4Z4_BZRg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 28 octobre 2011 =C3=A0 07:55 -0700, Linus Torvalds a =C3=A9=
crit :

> Maybe we should make it a generic helper macro ("ACCESS_AT_MOST_ONCE(=
)")?
>=20
> Comments? I think I'm open to tested patches..
>=20

I am currently travelling, but can do that Monday/Tuesday if nobody
beats me ;)
