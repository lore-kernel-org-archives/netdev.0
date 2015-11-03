From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sh_eth: use DMA barriers
Date: Tue, 03 Nov 2015 15:03:23 -0500 (EST)
Message-ID: <20151103.150323.2050849842791800571.davem@davemloft.net>
References: <1753153.kv41W3qdJQ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1753153.kv41W3qdJQ@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 03 Nov 2015 22:36:04 +0300

> Commit  7d7355f58ba4 ("sh_eth: Ensure proper ordering of descriptor active
> bit write/read") did the right thing  but used too "heavy" barriers while
> there were already "lighter" DMA barriers exactly  for this case...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
