From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Sat, 11 Jun 2011 13:39:50 +0200
Message-ID: <BANLkTinuDJNRDr9eAiyr4busLr4jiLvC1w@mail.gmail.com>
References: <20110609145657.96fae0d0.sfr@canb.auug.org.au>
	<BANLkTi=fn1qxcJGs7Ngag6ph2uMECiyWLg@mail.gmail.com>
	<20110611142648.bf71b026.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg KH <greg@kroah.com>, Alexey Dobriyan <adobriyan@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110611142648.bf71b026.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 11, 2011 at 06:26, Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
> On Fri, 10 Jun 2011 22:28:03 +0200 Geert Uytterhoeven <geert@linux-m6=
8k.org> wrote:
>> My first bisection between two successive versions of linux-next fai=
led, but
>
> Bisecting between successive linux-next versions is bound not to work=
=2E
> Bisection really only works between a commit and one of ist ancestors=
=2E

Yeah, I should have known that...

>> the second one between linus and linux-next just finished and points
>> to that commit.
>
> That is a much better bet.

Patch has been sent.

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
