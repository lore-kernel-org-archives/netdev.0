From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 02 Oct 2014 11:27:08 -0700 (PDT)
Message-ID: <20141002.112708.1359594783225203915.davem@davemloft.net>
References: <20141002141641.0e43a18e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, hayeswang@realtek.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141002141641.0e43a18e@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 2 Oct 2014 14:16:41 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/usb/r8152.c between commit 204c87041289 ("r8152: remove
> clearing bp") from the net tree and commit 8ddfa07778af ("r8152: use
> usleep_range") from the net-next tree.
> 
> I fixed it up (the former removed some of the code updated by the
> latter) and can carry the fix as necessary (no action is required).

I'm merging net into net-next today and thus resolving this.

Thanks Stephen!
