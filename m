From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: linux-next-20170320 break stmmac on dwmac-sunxi
Date: Tue, 21 Mar 2017 10:23:54 +0100
Message-ID: <c5d99767-0785-002d-1ac5-cf237fedbd38@st.com>
References: <20170320195406.GA19174@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:26178 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755537AbdCUJZn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 05:25:43 -0400
In-Reply-To: <20170320195406.GA19174@Red>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ Joao

please Joao, could you do a check if new changes have any impact on that?

peppe

On 3/20/2017 8:54 PM, Corentin Labbe wrote:
> Hello
>
> Just pushed next-20170320 to my boards and stmmac stop working on both intree dwmac-sunxi and my dev dwmac-sun8i.
> It seems that interrupts never fire, and transmit queue timeout.
> I will try to bisect this problem but perhaps other people could try to reproduce it.
>
> Regards
> Corentin Labbe
>
