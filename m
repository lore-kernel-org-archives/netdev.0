From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: manual merge of the staging tree with the net tree
Date: Thu, 13 Oct 2011 00:12:23 -0600
Message-ID: <20111013061223.GC23172@kroah.com>
References: <20111013164353.09c495e1b63d23e380cca1f7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arend van Spriel <arend@broadcom.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	Eliad Peller <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111013164353.09c495e1b63d23e380cca1f7@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 13, 2011 at 04:43:53PM +1100, Stephen Rothwell wrote:
> Hi Greg,
> 
> Today's linux-next merge of the staging tree got a conflicts in
> drivers/staging/brcm80211/brcmfmac/dhd_linux.c and
> drivers/staging/brcm80211/brcmsmac/mac80211_if.c between commits from the
> net-next tree and commit fc2d6e573be6 ("staging: brcm80211: remove
> brcm80211 driver from the staging tree") from the staging tree.
> 
> The latter removed the files, so I did that

Wonderful, thanks for doing that.

greg
