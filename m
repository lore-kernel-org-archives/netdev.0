From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: manual merge of the staging tree with the net tree
Date: Thu, 7 Jul 2011 06:43:16 -0700
Message-ID: <20110707134316.GC26939@kroah.com>
References: <20110707152857.83d48e1d1c175f811b255952@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jesper Juhl <jj@chaosbits.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110707152857.83d48e1d1c175f811b255952@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 07, 2011 at 03:28:57PM +1000, Stephen Rothwell wrote:
> Hi Greg,
> 
> Today's linux-next merge of the staging tree got a conflict in
> drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c between commit
> 219eb47e6f35 ("net/staging: add needed interrupt.h and hardirq.h
> includes") from the net tree and commit 41134db17a7d ("Remove unneeded
> version.h includes from drivers/staging/rtl*/") from the staging tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.

Looks correct, thanks.

greg k-h
