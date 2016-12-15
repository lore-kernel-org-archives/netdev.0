From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v2 2/2] net: ethernet: stmmac: remove private tx queue
 lock
Date: Thu, 15 Dec 2016 11:08:36 +0100
Message-ID: <c3d2816c-3c50-fd4b-16ea-912b321d51d0@st.com>
References: <1481241343-18062-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481241343-18062-3-git-send-email-LinoSanfilippo@gmx.de>
 <20161215094517.GA406@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <bh74.an@samsung.com>, <ks.giri@samsung.com>,
        <vipul.pandya@samsung.com>, <alexandre.torgue@st.com>,
        <romieu@fr.zoreil.com>, <davem@davemloft.net>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:25457 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1757902AbcLOKJC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 05:09:02 -0500
In-Reply-To: <20161215094517.GA406@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/2016 10:45 AM, Pavel Machek wrote:
> Giuseppe, is there documentation available for the chip? Driver says
>
>   Documentation available at:
>           http://www.stlinux.com
>
> but that page does not work for me...

Hi Pavel, yes the page has been removed but all the relevant and
updated driver doc is inside the kernel sources.

Regards
Peppe
