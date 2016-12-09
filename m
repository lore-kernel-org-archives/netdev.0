From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: Re: stmmac driver...
Date: Fri, 9 Dec 2016 18:05:00 +0800
Message-ID: <59b37368-8670-659a-c257-034f73a83136@synopsys.com>
References: <20161207.130654.1484281922991494182.davem@davemloft.net>
 <e8370557-b11a-0fe6-f87f-3af2e5990f27@st.com>
 <20161208.102552.714315690167693892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>,
        <CARLOS.PALMINHA@synopsys.com>, <Joao.Pinto@synopsys.com>
To: David Miller <davem@davemloft.net>, <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:60157 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751246AbcLIKFF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 05:05:05 -0500
In-Reply-To: <20161208.102552.714315690167693892.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/12/8 23:25, David Miller wrote:
> From: Alexandre Torgue <alexandre.torgue@st.com>
> Date: Thu, 8 Dec 2016 14:55:04 +0100
>
>> Maybe I forget some series. Do you have others in mind ?
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
>
Hi David and Alex,

XLGMAC is not a version of GMAC. Synopsys has several IPs and each IP has
several versions.

GMAC(QoS): 3.5, 3.7, 4.0, 4.10, 4.20...
XGMAC: 1.00, 1.10, 1.20, 2.00, 2.10, 2.11...
XLGMAC (Synopsys DesignWare Core Enterprise Ethernet): this is a new IP.

Regards,
Jie
