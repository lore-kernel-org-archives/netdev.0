From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: stmmac driver...
Date: Thu, 8 Dec 2016 14:55:04 +0100
Message-ID: <e8370557-b11a-0fe6-f87f-3af2e5990f27@st.com>
References: <20161207.130654.1484281922991494182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:43662 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751693AbcLHNzL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 08:55:11 -0500
In-Reply-To: <20161207.130654.1484281922991494182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 12/07/2016 07:06 PM, David Miller wrote:
>
> Giuseppe and Alexandre,
>
> There are a lot of patches and discussions happening around the stammc
> driver lately and both of you are listed as the maintainers.
>
> I really need prompt and conclusive reviews of these patch submissions
> from you, and participation in all discussions about the driver.
>
> Otherwise I have only three things I can do: 1) let the patches rot in
> patchwork for days 2) trust that the patches are sane and fit your
> desires and goals and just apply them or 3) reject them since they
> aren't being reviewed properly.

Sorry for the delay. I reviewed Niklas series this morning. I'm testing
"net: ethernet: stmmac: remove private tx queue lock".

Maybe I forget some series. Do you have others in mind ?

Regards
Alex
>
> Thanks in advance.
>
