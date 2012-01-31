From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: Remove unnecessary
 k.alloc/v.alloc OOM messages
Date: Tue, 31 Jan 2012 16:41:08 -0500 (EST)
Message-ID: <20120131.164108.1461389784443005673.davem@davemloft.net>
References: <1327877783.2652.10.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327877783.2652.10.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 29 Jan 2012 14:56:23 -0800

> alloc failures use dump_stack so emitting an additional
> out-of-memory message is an unnecessary duplication.
> 
> Remove the allocation failure messages.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
