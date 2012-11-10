From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Sat, 10 Nov 2012 18:34:31 -0500 (EST)
Message-ID: <20121110.183431.1207459372913956564.davem@davemloft.net>
References: <20121109105318.e24e2fa2b899af6e4d444b30@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, meravs@broadcom.com,
	dmitry@broadcom.com, eilong@broadcom.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20121109105318.e24e2fa2b899af6e4d444b30@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 9 Nov 2012 10:53:18 +1100

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c between commit
> 477864ddd365 ("bnx2x: Disable FCoE for 57840 since not yet supported by
> FW") from Linus' tree and commit 55c11941e382 ("bnx2x: Support loading
> cnic resources at run-time") from the net-next tree.
> 
> I fixed it up (I think - see below) and can carry the fix as necessary
> (no action is required).

I'm pulling 'net' into 'net-next' and this is exactly how I will resolve
this conflict.  Thanks Stephen.
