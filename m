From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with Linus' tree
Date: Sun, 28 Feb 2010 19:21:21 -0800 (PST)
Message-ID: <20100228.192121.244104789.davem@davemloft.net>
References: <20100301142002.ee497fd8.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, joe@perches.com,
	hartleys@visionengravers.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100301142002.ee497fd8.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 1 Mar 2010 14:20:02 +1100

> Today's linux-next merge of the net tree got a conflict in
> drivers/firmware/iscsi_ibft.c between commit
> 00e7825b943f486e80ff1305cd0594d8791870f8 ("drivers/firmware/iscsi_ibft.c:
> remove NIPQUAD_FMT, use %pI4") from Linus' tree and commit
> 2c35294853b2e977bdfc9e401b7b6d881fcaa69b ("drivers/firmware/iscsi_ibft.c:
> use %pM to show MAC address") from the net tree.
> 
> Just a trivial context change.  I fixed it up and can carry the change as
> necessary.

Thanks Stephen, I'll fix this up.
