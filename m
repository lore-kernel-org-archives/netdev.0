From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 30 Apr 2013 04:04:28 -0400 (EDT)
Message-ID: <20130430.040428.2200075465405704834.davem@davemloft.net>
References: <20130430122423.ab57c82604f13f6773ef4aeb@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, gang.chen@asianux.com,
	alan@signal11.us
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130430122423.ab57c82604f13f6773ef4aeb@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 30 Apr 2013 12:24:23 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> net/mac802154/mac802154.h between commit 2c1bbbffa0b6 ("net: mac802154:
> comparision issue of type cast, finding by EXTRA_CFLAGS=-W") from the net
> tree and commit 7dd43d356e73 ("mac802154: Do not try to resend failed
> packets") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

This should be taken care of as well, thanks Stephen.
