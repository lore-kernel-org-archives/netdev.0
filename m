From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: manual merge of the staging tree with the net-next
 tree
Date: Mon, 17 Mar 2014 11:30:10 -0700
Message-ID: <20140317183010.GB10565@kroah.com>
References: <20140317190842.795b9d29db9a131a9cff91a9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"Zhao, Gang" <gamerh2o@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140317190842.795b9d29db9a131a9cff91a9@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 17, 2014 at 07:08:42PM +1100, Stephen Rothwell wrote:
> Hi Greg,
> 
> Today's linux-next merge of the staging tree got a conflict in
> drivers/staging/wlan-ng/cfg80211.c between commit 3ead0d2e220e ("wlan-ng:
> fixup staging driver for removal of ieee80211_dsss_chan_to_freq") from
> the net-next tree and commit 4e5e9d7c66f0 ("staging: wlan-ng: replace
> function ieee80211_dsss_chan_to_freq()") from the staging tree.
> 
> I fixed it up (I used the staging tree version) and can carry the fix as
> necessary (no action is required).

Thanks, that sounds correct.

greg k-h
