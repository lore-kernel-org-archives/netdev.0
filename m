From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: manual merge of the net-next tree with the  tree
Date: Mon, 5 Dec 2011 09:53:21 -0500
Message-ID: <20111205145320.GA2531@tuxdriver.com>
References: <20111205123428.47213da24624d85aa84711f3@canb.auug.org.au>
 <20111205153416.e1dd01e5368ce7c016d99a59@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Johannes Berg <johannes.berg@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111205153416.e1dd01e5368ce7c016d99a59@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 05, 2011 at 03:34:16PM +1100, Stephen Rothwell wrote:
> On Mon, 5 Dec 2011 12:34:28 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> >
> > Today's linux-next merge of the net-next tree got a conflict in
> > drivers/net/wireless/iwlwifi/iwl-agn.c between commits from the
> 
> wireless (sorry)
> 
> > tree and commit 7335613ae27a ("iwlwifi: move all mac80211 related
> > functions to one place") from the net-next tree.
> > 
> > I just used the net-next version (which may require some fixes).

Yeah, I'll try to get that straightened-out over the next day or two.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
