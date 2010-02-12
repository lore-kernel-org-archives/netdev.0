From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] virtio_net: remove send queue
Date: Fri, 12 Feb 2010 12:28:23 -0800 (PST)
Message-ID: <20100212.122823.149317307.davem@davemloft.net>
References: <1265674482.4484.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org, rusty@rustcorp.com.au,
	mst@redhat.com, linux-kernel@vger.kernel.org
To: mashirle@us.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265674482.4484.10.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shirley Ma <mashirle@us.ibm.com>
Date: Mon, 08 Feb 2010 16:14:42 -0800

> Now we have a virtio detach API (in commit
> f9bfbebf34eab707b065116cdc9699d25ba4252a), we don't need to track xmit
> skbs in the virio_net driver, which improves transmission performance.
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> Acked-by: Rusty Russell <rusty@rustcorp.com.au>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied to net-next-2.6, thanks everyone.
