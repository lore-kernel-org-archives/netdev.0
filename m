From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] SubmittingPatches: clarify SOB tag usage when evolving
 submissions
Date: Wed, 15 Aug 2012 11:23:01 +0300
Message-ID: <20120815082301.GA1359@mwanda>
References: <1344545493-6820-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, rdunlap@xenotime.net, tytso@mit.edu,
	alan@lxorguk.ukuu.org.uk, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1344545493-6820-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think it would be nice to have another tag for people who fix bugs
in the original patch.  The Reviewed-by tag implies approval of the
whole patch and anyway reviewers don't normally comment unless they
see a bug.  Maybe something like:

Contributor: Your Name <email@address.com>

So the tags for developers would be:

Signed-off-by:  The patch went through you.  Legal responsibility.
Acked-by:  You know what you are talking about and approve.
Reviewed-by:  You reviewed the patch and approve.
Contributor:  You noticed or fixed a bug in the patch.

regards,
dan carpenter
