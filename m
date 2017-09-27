From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Meet alignment requirements for DMA
Date: Tue, 26 Sep 2017 19:52:44 -0700 (PDT)
Message-ID: <20170926.195244.506518182147628099.davem@davemloft.net>
References: <71740323.RRBhnhefTi@np-p-burton>
        <20170926.133309.1916643567158187651.davem@davemloft.net>
        <1752163.uYYNevmZpH@np-p-burton>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matt.redfearn@imgtec.com, netdev@vger.kernel.org,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        james.hogan@imgtec.com
To: paul.burton@imgtec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1752163.uYYNevmZpH@np-p-burton>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Burton <paul.burton@imgtec.com>
Date: Tue, 26 Sep 2017 14:30:33 -0700

> I'd suggest that at a minimum if you're unwilling to obey the API as
> described in Documentation/DMA-API.txt then it would be beneficial
> if you could propose a change to it such that it works for you, and
> perhaps we can extend the API & its documentation to allow your
> usage whilst also allowing us to catch broken uses.

The networking driver code works fine as is.

I also didn't write that ill-advised documentation in the DMA docs,
nor the non-merged new MIPS assertion.

So I'm trying to figure out on what basis I am required to do
anything.

Thank you.
