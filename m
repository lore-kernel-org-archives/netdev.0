From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH trivial 2/4] rtlwifi: rtl8821ae: Spelling
 s/wrtie_addr/write_addr/
Date: Fri, 17 Feb 2017 10:42:15 -0600
Message-ID: <42689efd-f0f8-5a61-c787-cda22bf6ef68@lwfinger.net>
References: <1487345799-1638-1-git-send-email-geert+renesas@glider.be>
 <1487345799-1638-2-git-send-email-geert+renesas@glider.be>
 <2c7a3011-3418-35a5-ca2e-88c0188baccf@lwfinger.net>
 <CAMuHMdV0QRG4py3f4LTF-D43hh14=771QqR9hN+tvAbppNS5TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        Jiri Kosina <trivial@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdV0QRG4py3f4LTF-D43hh14=771QqR9hN+tvAbppNS5TQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/17/2017 10:19 AM, Geert Uytterhoeven wrote:
> Hi Larry,
>
> On Fri, Feb 17, 2017 at 5:14 PM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
>> On 02/17/2017 09:36 AM, Geert Uytterhoeven wrote:
>>> As per symmetry with _rtl8821ae_dbi_read(), "wrtie" is not a funky
>>> register acronym, but a simple misspelling of "write".
>>>
>>> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
>>> Cc: Larry Finger <Larry.Finger@lwfinger.net>
>>> Cc: Chaoming Li <chaoming_li@realsil.com.cn>
>>> Cc: netdev@vger.kernel.org
>>
>> I'm not sure that it is possible to have a typo in a variable name. That
>> seems to be within an author's prerogative. Nonetheless, the patch is OK
>
> ;-)
>
>> other than it was sent to the wrong destination. Patches for this driver
>
> MAINTAINERS has your name for drivers/net/wireless/realtek/rtlwifi/.
> Perhaps that line should be dropped?

The usual hierarchy is through me to Kalle, then to DaveM, and finally to mainline.

>> should go through linux-wireless@vger.kernel.org. Kalle Valo is the wireless
>> maintainer, but it is not necessary to send to him directly as he usually
>> picks up the patches from Patchwork.
>
> I guess Jiri (trivial) will pick it up...

The only potential problem would be conflicts arising from changes merging from 
two different directions. It applies to Kalle's wireless-drivers-next branch, 
and I will try to keep it in mind as additional patches are supplied to rtl8821ae.

Larry
