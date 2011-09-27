From: wwguy <wey-yi.w.guy@intel.com>
Subject: Re: linux-next: manual merge of the net tree with the
 wireless-current tree
Date: Tue, 27 Sep 2011 07:41:41 -0700
Message-ID: <1317134501.9384.0.camel@wwguy-ubuntu>
References: <20110927125132.002db8176a66f85286dcd027@canb.auug.org.au>
	 <20110927130926.GA2824@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110927130926.GA2824@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-09-27 at 06:09 -0700, John W. Linville wrote:
> On Tue, Sep 27, 2011 at 12:51:32PM +1000, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Today's linux-next merge of the net tree got a conflict in
> > drivers/net/wireless/iwlwifi/iwl-scan.c between commit 6c80c39d9a69
> > ("iwlagn: fix dangling scan request") from the wireless-current tree and
> > commits 63013ae30159 ("iwlagn: priv->status moves to iwl_shared") and
> > 6ac2f839b0b2 ("iwlagn: priv->mutex moves to iwl_shared") from the net
> > tree.
> > 
> > I fixed it up (see below) and can carry the fix as necessary.
> 
> Looks good, thanks!
> 
Thanks a lot for fixing it.

Wey
