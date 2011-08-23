From: Niklaus Giger <niklaus.giger@member.fsf.org>
Subject: Re: linux-next: manual merge of the net tree with the  tree
Date: Tue, 23 Aug 2011 20:10:44 +0200
Message-ID: <201108232010.46421.niklaus.giger@member.fsf.org>
References: <20110822115118.e5d97beb22befc4ba9396e9d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Josh Boyer <jwboyer@gmail.com>,
	Tony Breeds <tony@bakeyournoodle.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110822115118.e5d97beb22befc4ba9396e9d@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> arch/powerpc/configs/40x/hcu4_defconfig between commit 9fcd768d0cc8
> ("powerpc/40x: Remove obsolete HCU4 board") from the 4xx tree and commit
> 3b3bceef26f8 ("net: fix IBM EMAC driver after rename") from the net tree.
> 
> The former commit removes the file, so I just did that.
Thanks!

Best regards
