From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: manual merge of the net tree with the
	wireless-current tree
Date: Tue, 1 Dec 2009 09:06:58 -0500
Message-ID: <20091201140658.GA11031@tuxdriver.com>
References: <20091201123142.fe6bc824.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091201123142.fe6bc824.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 01, 2009 at 12:31:42PM +1100, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in net/mac80211/ht.c between commit 827d42c9ac91ddd728e4f4a31fefb906ef2ceff7 ("mac80211: fix spurious delBA handling") from the wireless-current tree and commit c951ad3550ab40071bb0f222ba6125845769c08a ("mac80211: convert aggregation to operate on vifs/stas") from the net tree.
> 
> I fixed it up (by using the version from the wireless-current tree) and
> can carry the fix as necessary.  This may well not be correct.

That sounds like the correct fix...thanks!

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
