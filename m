From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 25 Jun 2012 16:04:37 -0700 (PDT)
Message-ID: <20120625.160437.1414802196489079213.davem@davemloft.net>
References: <20120625133318.a57079c86bad4360828efac0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, bjorn@mork.no
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120625133318.a57079c86bad4360828efac0@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 25 Jun 2012 13:33:18 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/usb/qmi_wwan.c between commit b9f90eb27402 ("net: qmi_wwan:
> fix Gobi device probing") from the net tree and various commits from the
> net-next tree.
> 
> I am not sure how to fix this, but the comments in the net tree commit
> implied that it would be placed in the 3.6 code, so I just used the
> version of this file from the net-next tree.

I've resolved this during today's net --> net-next merge.
