From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] net: l2tp: deprecate PPPOL2TP_MSG_* in
 favour of L2TP_MSG_*
Date: Sat, 10 Dec 2016 23:29:29 -0500 (EST)
Message-ID: <20161210.232929.2033391278175655696.davem@davemloft.net>
References: <20161211001859.10333-1-asbjorn@asbjorn.st>
        <20161211001859.10333-2-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: asbjorn@asbjorn.st
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161211001859.10333-2-asbjorn@asbjorn.st>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Date: Sun, 11 Dec 2016 00:18:58 +0000

> PPPOL2TP_MSG_* and L2TP_MSG_* are duplicates, and are being used
> interchangeably in the kernel, so let's standardize on L2TP_MSG_*
> internally, and keep PPPOL2TP_MSG_* defined in UAPI for compatibility.
> 
> Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>

Applied.
