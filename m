From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Fri, 21 Nov 2014 22:30:22 -0500 (EST)
Message-ID: <20141121.223022.399609321644415888.davem@davemloft.net>
References: <20141117133404.525229b4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jrajahalme@nicira.com,
	pshelar@nicira.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20141117133404.525229b4@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 17 Nov 2014 13:34:04 +1100

> I applied the following merge fix patch:
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 17 Nov 2014 13:31:33 +1100
> Subject: [PATCH] openvswitch: fix up for OVS_NLERR API change
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Thanks Stephen, I integrated this into the merge commit when
I merge net into net-next just now.

Thanks again.
