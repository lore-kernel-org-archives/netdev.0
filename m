From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH trivial 2/4] rtlwifi: rtl8821ae: Spelling s/wrtie_addr/write_addr/
Date: Fri, 17 Feb 2017 17:19:59 +0100
Message-ID: <CAMuHMdV0QRG4py3f4LTF-D43hh14=771QqR9hN+tvAbppNS5TQ@mail.gmail.com>
References: <1487345799-1638-1-git-send-email-geert+renesas@glider.be>
 <1487345799-1638-2-git-send-email-geert+renesas@glider.be> <2c7a3011-3418-35a5-ca2e-88c0188baccf@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        Jiri Kosina <trivial@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2c7a3011-3418-35a5-ca2e-88c0188baccf@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Larry,

On Fri, Feb 17, 2017 at 5:14 PM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> On 02/17/2017 09:36 AM, Geert Uytterhoeven wrote:
>> As per symmetry with _rtl8821ae_dbi_read(), "wrtie" is not a funky
>> register acronym, but a simple misspelling of "write".
>>
>> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
>> Cc: Larry Finger <Larry.Finger@lwfinger.net>
>> Cc: Chaoming Li <chaoming_li@realsil.com.cn>
>> Cc: netdev@vger.kernel.org
>
> I'm not sure that it is possible to have a typo in a variable name. That
> seems to be within an author's prerogative. Nonetheless, the patch is OK

;-)

> other than it was sent to the wrong destination. Patches for this driver

MAINTAINERS has your name for drivers/net/wireless/realtek/rtlwifi/.
Perhaps that line should be dropped?

> should go through linux-wireless@vger.kernel.org. Kalle Valo is the wireless
> maintainer, but it is not necessary to send to him directly as he usually
> picks up the patches from Patchwork.

I guess Jiri (trivial) will pick it up...

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
