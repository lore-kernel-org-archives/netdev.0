From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: stmmac driver...
Date: Thu, 8 Dec 2016 16:49:40 +0100
Message-ID: <f3aff12e-70f9-5720-6ec6-ef7cd7b59ebc@st.com>
References: <20161207.130654.1484281922991494182.davem@davemloft.net>
 <e8370557-b11a-0fe6-f87f-3af2e5990f27@st.com>
 <20161208.102552.714315690167693892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:48103 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753957AbcLHPtq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 10:49:46 -0500
In-Reply-To: <20161208.102552.714315690167693892.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/08/2016 04:25 PM, David Miller wrote:
> From: Alexandre Torgue <alexandre.torgue@st.com>
> Date: Thu, 8 Dec 2016 14:55:04 +0100
>
>> Maybe I forget some series. Do you have others in mind ?
>
> Please see the thread titled:
>
> "net: ethernet: Initial driver for Synopsys DWC XLGMAC"
>
> which seems to be discussing consolidation of various drivers
> for the same IP core, of which stmmac is one.
>
> I personally am against any change of the driver name and
> things like this, and wish the people doing that work would
> simply contribute to making whatever changes they need directly
> to the stmmac driver.
>
> You really need to voice your opinion when major changes are being
> proposed for the driver you maintain.

For sure I agree. I miss this one as it doesn't modify (yet) stmmac 
driver. I gonna respond to the thread;

Regards
Alex

>
