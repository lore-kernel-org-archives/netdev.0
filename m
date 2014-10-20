From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: v3.18-rc1 bloat-o-meter
Date: Mon, 20 Oct 2014 11:09:28 +0200
Message-ID: <CAMuHMdV5VPEqJ2WeZTc=Tg_vSRJPYgzQib9m-_fnqLzJ_vpDdA@mail.gmail.com>
References: <alpine.DEB.2.02.1410201018230.24954@ayla.of.borg>
	<20141020090637.GA3654@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Embedded <linux-embedded@vger.kernel.org>,
	Josh Triplett <josh@joshtriplett.org>,
	Linux Kernel Development <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Borislav Petkov <bp@alien8.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141020090637.GA3654@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Boris,

On Mon, Oct 20, 2014 at 11:06 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Mon, Oct 20, 2014 at 10:37:19AM +0200, Geert Uytterhoeven wrote:
>>       Hi all,
>>
>> Below is the bloat-o-meter output when comparing an m68k/atari_defconfig
>> kernel for v3.17 and v3.18-rc1.
>
> That looks cool, can I run this for other arches too?

Sure. Compile two kernel images, and run

    scripts/bloat-o-meter <image1> <image2>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
