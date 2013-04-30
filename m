From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 30 Apr 2013 04:02:51 -0400 (EDT)
Message-ID: <20130430.040251.1648116137288414643.davem@davemloft.net>
References: <20130426132447.c7b06622240088ccad366b03@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ariele@broadcom.com,
	yuvalmin@broadcom.com, eilong@broadcom.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130426132447.c7b06622240088ccad366b03@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 26 Apr 2013 13:24:47 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c between commit
> ecf01c22be03 ("bnx2x: Prevent NULL pointer dereference in kdump") from
> the net tree and commit 5b0752c863d7 ("bnx2x: Fix VF statistics") from
> the net-next tree.
> 
> I am not sure about this, but I just used the net tree version but I
> assume something more may be needed and can carry the fix as necessary (no
> action is required).

I've just resolved this when I merged net into net-next.
