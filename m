From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Wed, 28 Sep 2011 01:36:52 -0400 (EDT)
Message-ID: <20110928.013652.1712671417837562954.davem@davemloft.net>
References: <20110928125428.70d5cf10ea59f729135d5dff@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ordex@autistici.org,
	lindner_marek@yahoo.de
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110928125428.70d5cf10ea59f729135d5dff@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 28 Sep 2011 12:54:28 +1000

> Today's linux-next merge of the net tree got a conflict in
> net/batman-adv/soft-interface.c between commit 8b267b312df9 ("batman-adv:
> do_bcast has to be true for broadcast packets only") from the net-current
> tree and commit 3d393e473210 ("batman-adv: implement AP-isolation on the
> sender side") from the net tree.
> 
> Just context changes.  I fixed it up (see below) and can carry the fix as
> necessary.

Yep, I'll do a merge soon to fix this up for good, thanks Stephen!
