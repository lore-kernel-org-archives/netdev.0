From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] net: rds: use for_each_sg() for
 scatterlist parsing
Date: Sun, 21 Jun 2015 09:32:22 -0700 (PDT)
Message-ID: <20150621.093222.690590054409339964.davem@davemloft.net>
References: <1434480247-22072-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, chien.yen@oracle.com,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434480247-22072-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Tue, 16 Jun 2015 20:44:07 +0200

> This patch also renames sg to sglist and aligns function parameters.
> See Documentation/DMA-API.txt - Part Id for scatterlist details
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
> This is untested.
> V2: reorder variables (suggested by David S. Miller)

Applied, thanks.
