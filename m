From: Peter Robinson <pbrobinson@gmail.com>
Subject: Re: [PATCH 1/2] ethernet: stmmac: make DWMAC_STM32 depend on it's
 associated SoC
Date: Wed, 16 Nov 2016 14:01:58 +0000
Message-ID: <CALeDE9PfMU4M4JbTDfHY5Yfo9rz4EMBgu54knkEf=_yNnTTvyQ@mail.gmail.com>
References: <20161106200437.12312-1-pbrobinson@gmail.com> <20161106.214128.668519501329683090.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mcoquelin.stm32@gmail.com, alexandre.torgue@st.com,
        peppe.cavallaro@st.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36793 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751953AbcKPOCA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:02:00 -0500
Received: by mail-wm0-f52.google.com with SMTP id g23so241690887wme.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:01:59 -0800 (PST)
In-Reply-To: <20161106.214128.668519501329683090.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 7, 2016 at 2:41 AM, David Miller <davem@davemloft.net> wrote:
> From: Peter Robinson <pbrobinson@gmail.com>
> Date: Sun,  6 Nov 2016 20:04:37 +0000
>
>> There's not much point, except compile test, enabling the stmmac
>> platform drivers unless the STM32 SoC is enabled. It's not
>> useful without it.
>>
>> Signed-off-by: Peter Robinson <pbrobinson@gmail.com>
>
> Please don't post just some of the patches in a patch series.
>
> Always post the complete series, with a proper "[PATCH 0/2] ..."
> posting at the beginning.

Sorry, it was a stm branch, I should have broke it our differently. I
can recompose and send this one again on it's own.

Peter
