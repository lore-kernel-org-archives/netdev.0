From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 25 Jun 2012 16:04:52 -0700 (PDT)
Message-ID: <20120625.160452.987297805118709913.davem@davemloft.net>
References: <20120625133812.aad5804dca97e504650b7dd1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ordex@autistici.org,
	sven@narfation.org
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120625133812.aad5804dca97e504650b7dd1@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 25 Jun 2012 13:38:12 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> net/batman-adv/translation-table.c between commit 8b8e4bc0391f
> ("batman-adv: fix race condition in TT full-table replacement") from the
> net tree and commit 7d211efc5087 ("batman-adv: Prefix originator
> non-static functions with batadv_") from the net-next tree.
> 
> Just context changes.  I fixed it up (see below) and can carry the fix as
> necessary.

I've also resolved this during today's net --> net-next merge.
