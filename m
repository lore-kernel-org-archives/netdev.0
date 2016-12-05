From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net 00/20] Increase ENA driver version to 1.1.2
Date: Sun, 04 Dec 2016 21:37:43 -0500 (EST)
Message-ID: <20161204.213743.1610654756480441815.davem@davemloft.net>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        dwmw@amazon.com, zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: netanel@annapurnalabs.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It is not appropriate to submit so many patches at one time.

Please keep your patch series to no more than about a dozen
at a time.

Also, group your changes logically and tie an appropriately
descriptive cover letter.

"Increase driver version to X.Y.Z" tells the reader absolutely
nothing.  Someone reading that Subject line in the GIT logs
will have no idea what the overall purpose of the patch series
is and what it accomplishes.

You really need to describe the high level purpose of the patch set.
Is it adding a new feature?  What is that feature?  Why are you
adding that feature?  How is that feature implemented?  Why is
it implemented that way?
