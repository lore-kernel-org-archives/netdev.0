From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [net-next PATCH 0/7] stmmac: dwmac-sti refactor+cleanup
Date: Fri, 4 Nov 2016 17:19:03 +0100
Message-ID: <CAGhQ9VxzRLLB1_GyvZGE_XSB-RL8_6AvmAi219dt_8HW3_3BLg@mail.gmail.com>
References: <20161030200507.851-1-manabian@gmail.com> <5eb811e8-0d1d-2e9e-245c-043a07c87bca@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, alexandre.torgue@st.com,
        netdev <netdev@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:35451 "EHLO
        mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934706AbcKDQTE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 12:19:04 -0400
Received: by mail-yw0-f181.google.com with SMTP id h14so93406705ywa.2
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 09:19:04 -0700 (PDT)
In-Reply-To: <5eb811e8-0d1d-2e9e-245c-043a07c87bca@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Giuseppe,

On 4 November 2016 at 14:49, Giuseppe CAVALLARO <peppe.cavallaro@st.com> wrote:
> Hello Joachim.
>
> I have tested the patches on STiH390 with GMAC4 and the driver is ok.
>
> So you can add my Acked-by/Tested-by in the V2.

Thanks! I'll send a V2 later today or tomorrow.


> I just ask you, when rename the sti_dwmac_init in sti_dwmac_set_phy_mode
> to use another name: sti_dwmac_set_mode could be good, IMO.

Sure thing.


regards,
Joachim Eastwood
