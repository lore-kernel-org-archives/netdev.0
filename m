From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: manual merge of the staging tree with the net and
 wireless trees
Date: Tue, 4 Oct 2011 08:25:22 -0700
Message-ID: <20111004152522.GA29994@kroah.com>
References: <20111004171449.de5c45332510a453cc3ff879@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eliad Peller <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111004171449.de5c45332510a453cc3ff879@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 04, 2011 at 05:14:49PM +1100, Stephen Rothwell wrote:
> Hi Greg,
> 
> Today's linux-next merge of the staging tree got a conflict in
> drivers/staging/brcm80211/brcmsmac/mac80211_if.c between commit
> 37a41b4affa3 ("mac80211: add ieee80211_vif param to tsf functions") from
> the net tree, commit 8a3a3c85e44d ("mac80211: pass vif param to conf_tx()
> callback") from the wireless tree and several commits from the staging
> tree.
> 
> I fixed it up (just removed the forward declarions that were changed by
> the former commits) and can carry the fix as necessary.

Thanks, that sounds correct.

Aren't you happy my trees are back now?  :)

greg k-h
