From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: manual merge of the net tree with the
 wireless-current tree
Date: Tue, 27 Sep 2011 09:09:27 -0400
Message-ID: <20110927130926.GA2824@tuxdriver.com>
References: <20110927125132.002db8176a66f85286dcd027@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110927125132.002db8176a66f85286dcd027@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 27, 2011 at 12:51:32PM +1000, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> drivers/net/wireless/iwlwifi/iwl-scan.c between commit 6c80c39d9a69
> ("iwlagn: fix dangling scan request") from the wireless-current tree and
> commits 63013ae30159 ("iwlagn: priv->status moves to iwl_shared") and
> 6ac2f839b0b2 ("iwlagn: priv->mutex moves to iwl_shared") from the net
> tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.

Looks good, thanks!

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
