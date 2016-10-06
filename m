From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] ethernet: qualcomm: QCOM_EMAC should depend on HAS_DMA
Date: Thu, 6 Oct 2016 09:12:03 -0500
Message-ID: <57F65BB3.3090602@codeaurora.org>
References: <1475762253-16759-1-git-send-email-geert@linux-m68k.org>
 <57F65A73.7020701@codeaurora.org>
 <CAMuHMdUGB6__ExtGTCpxOBXBG_=L9GNy1-g10VuCtqZvWRV5Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33796 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752960AbcJFOMG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 10:12:06 -0400
In-Reply-To: <CAMuHMdUGB6__ExtGTCpxOBXBG_=L9GNy1-g10VuCtqZvWRV5Tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geert Uytterhoeven wrote:
> Probably, I don't do UML allmodconfig builds.
>
> Gr{oetje,eeting}s,

Would you mind submitting another version of your patch that includes 
HAS_DMA and HAS_IOMEM, so that both build breaks can be fixed in one shot?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
