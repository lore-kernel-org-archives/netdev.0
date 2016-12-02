From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: atarilance: use %8ph for printing hex string
Date: Fri, 02 Dec 2016 12:03:56 -0500 (EST)
Message-ID: <20161202.120356.1706869930593696785.davem@davemloft.net>
References: <1480543375-28904-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felipe.balbi@linux.intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linux@rasmusvillemoes.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480543375-28904-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Wed, 30 Nov 2016 23:02:54 +0100

> This is already using the %pM printf extension; might as well also use
> %ph to make the code smaller.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Applied, thank you.
