From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Discard masked flags in interrupt status
 register
Date: Wed, 01 Feb 2017 16:02:52 -0500 (EST)
Message-ID: <20170201.160252.465001917585166032.davem@davemloft.net>
References: <1485519883-24969-1-git-send-email-abrodkin@synopsys.com>
        <20170129.181541.423447436903187089.davem@davemloft.net>
        <4881796E12491D4BB15146FE0209CE64678ACDB7@DE02WEMBXB.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, peppe.cavallaro@st.com,
        fabrice.gasnier@st.com, manabian@gmail.com,
        preid@electromag.com.au, alexandre.torgue@gmail.com,
        Vineet.Gupta1@synopsys.com
To: Alexey.Brodkin@synopsys.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <4881796E12491D4BB15146FE0209CE64678ACDB7@DE02WEMBXB.internal.synopsys.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Date: Wed, 1 Feb 2017 20:22:22 +0000

> May we have that one back-ported to stable branches starting from 4.8.x?
> 
> That issue started to appear due to a change from pr_debug() to pr_info() in commit
> 70523e639bf8 ("drivers: net: stmmac: reworking the PCS code.").

Sure, queued up for -stable.

Thanks.
