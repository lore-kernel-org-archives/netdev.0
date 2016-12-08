From: David Miller <davem@davemloft.net>
Subject: Re: stmmac driver...
Date: Thu, 08 Dec 2016 10:25:52 -0500 (EST)
Message-ID: <20161208.102552.714315690167693892.davem@davemloft.net>
References: <20161207.130654.1484281922991494182.davem@davemloft.net>
        <e8370557-b11a-0fe6-f87f-3af2e5990f27@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32816 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751827AbcLHPZy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 10:25:54 -0500
In-Reply-To: <e8370557-b11a-0fe6-f87f-3af2e5990f27@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre Torgue <alexandre.torgue@st.com>
Date: Thu, 8 Dec 2016 14:55:04 +0100

> Maybe I forget some series. Do you have others in mind ?

Please see the thread titled:

"net: ethernet: Initial driver for Synopsys DWC XLGMAC"

which seems to be discussing consolidation of various drivers
for the same IP core, of which stmmac is one.

I personally am against any change of the driver name and
things like this, and wish the people doing that work would
simply contribute to making whatever changes they need directly
to the stmmac driver.

You really need to voice your opinion when major changes are being
proposed for the driver you maintain.
