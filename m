From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Sun, 08 Nov 2009 20:59:11 -0800 (PST)
Message-ID: <20091108.205911.177751843.davem@davemloft.net>
References: <20091109130323.5dcc7829.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, wg@grandegger.com,
	haas@ems-wuensche.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091109130323.5dcc7829.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 9 Nov 2009 13:03:23 +1100

> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> drivers/net/can/usb/ems_usb.c between commit
> 2b2072e902848a63168570f500a5726744b3873a ("ems_usb: Fix byte order issues
> on big endian machines") from the net-current tree and commit
> 7b6856a0296a8f187bb88ba31fa83a08abba7966 ("can: provide library functions
> for skb allocation") from the net tree.
> 
> Just context changes.  I fixed it up (see below) and can carry the fix
> for a while.

I'll do a merge and resolve this, thanks Stephen!
