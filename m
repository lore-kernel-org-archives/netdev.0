From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make __skb_splice_bits static
Date: Wed, 16 Jul 2008 20:12:40 -0700 (PDT)
Message-ID: <20080716.201240.150812340.davem@davemloft.net>
References: <1216237880.28841.20.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1216237880.28841.20.camel@brick>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Wed, 16 Jul 2008 12:51:20 -0700

> net/core/skbuff.c:1335:5: warning: symbol '__skb_splice_bits' was not declared. Should it be static?
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks Harvey.
