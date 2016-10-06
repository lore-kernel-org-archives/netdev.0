From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ethernet: qualcomm: QCOM_EMAC should depend on HAS_DMA
Date: Thu, 6 Oct 2016 16:45:06 +0200
Message-ID: <CAMuHMdW_KXxukwsPmpY-pF73++H+cy45-39JX33oUTLgypx8eA@mail.gmail.com>
References: <1475762253-16759-1-git-send-email-geert@linux-m68k.org>
 <57F65A73.7020701@codeaurora.org> <CAMuHMdUGB6__ExtGTCpxOBXBG_=L9GNy1-g10VuCtqZvWRV5Tg@mail.gmail.com>
 <57F65BB3.3090602@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35104 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755551AbcJFOpJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 10:45:09 -0400
In-Reply-To: <57F65BB3.3090602@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 6, 2016 at 4:12 PM, Timur Tabi <timur@codeaurora.org> wrote:
> Geert Uytterhoeven wrote:
>>
>> Probably, I don't do UML allmodconfig builds.
>>
>> Gr{oetje,eeting}s,
>
>
> Would you mind submitting another version of your patch that includes
> HAS_DMA and HAS_IOMEM, so that both build breaks can be fixed in one shot?

Done.

Gr{oetje,eeting}s,

                        Geert
