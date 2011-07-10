From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [RFC 43/72] a2065/ariadne: Move the a2065/ariadne drivers
Date: Sun, 10 Jul 2011 21:34:18 +0200
Message-ID: <CAMuHMdVHRNk4arc75QKrzDmHYE+86NixPk6v9uGwOAPkUTCgJw@mail.gmail.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1309010363-22750-44-git-send-email-jeffrey.t.kirsher@intel.com>
	<BANLkTin_SRhrd4dnfBH48b1aTikw5-mjtg@mail.gmail.com>
	<1310221836.26989.11.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55149 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756610Ab1GJTeT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2011 15:34:19 -0400
Received: by iyb12 with SMTP id 12so3106061iyb.19
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2011 12:34:19 -0700 (PDT)
In-Reply-To: <1310221836.26989.11.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 9, 2011 at 16:30, Jeff Kirsher <jeffrey.t.kirsher@intel.com=
> wrote:
> On Tue, 2011-06-28 at 13:33 -0700, Geert Uytterhoeven wrote:
>> And (in some other patch) 82596.c is an Intel driver, not a Motorola=
 driver.
>
> 82596.c is not an Intel driver, it is an Intel part. =C2=A0The driver=
 was

Sorry, I meant "driver for an Intel part".

> written and support by someone other than Intel. =C2=A0I am looking a=
t how to

Sure. But I'm strongly against classifying drivers based on who wrote t=
hem ;-)

> better organize the 82596.c, lasi_82596.c, lib82596.c, and sni_82596.=
c
> which all use an Intel Ethernet chip but were written and supported b=
y
> someone other than Intel.

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
