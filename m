From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: disable tx coalescing
Date: Sun, 11 Dec 2016 14:31:13 -0500 (EST)
Message-ID: <20161211.143113.268450274785467682.davem@davemloft.net>
References: <20161124.110416.198867271899443489.davem@davemloft.net>
        <20161205122711.GA30774@amd>
        <20161211190750.GA14287@amd>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.torgue@st.com,
        LinoSanfilippo@gmx.de
To: pavel@ucw.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161211190750.GA14287@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Machek <pavel@ucw.cz>
Date: Sun, 11 Dec 2016 20:07:50 +0100

> David, ping? Can I get you to apply this one?
> 
> As you noticed, tx coalescing is completely broken in that driver, and
> not easy to repair. This is simplest way to disable it. It can still
> be re-enabled from userspace, so code can be fixed in future.

Sorry I'm not applying this, I want you and the driver maintainer
to reach a real solution.
