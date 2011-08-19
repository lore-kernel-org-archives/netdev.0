From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: manual merge of the wireless tree with the net tree
Date: Thu, 18 Aug 2011 18:03:35 -0700
Message-ID: <20110819010334.GC2487@tuxdriver.com>
References: <20110819105946.a46aa8a997f466d8a2e7f2f3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110819105946.a46aa8a997f466d8a2e7f2f3@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 19, 2011 at 10:59:46AM +1000, Stephen Rothwell wrote:
> Hi John,
> 
> Today's linux-next merge of the wireless tree got a conflict in
> drivers/staging/ath6kl/os/linux/ar6000_drv.c between commit afc4b13df143
> ("net: remove use of ndo_set_multicast_list in drivers") from the net
> tree and commit af2bf4b4ee58 ("staging: remove ath6kl") from the wireless
> tree.
> 
> I just removed the file.

Cool, thanks.  I imagine that any more "bombing runs" that touch
ath6kl in staging will be able to resolved in the same fashion.

Thanks!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
