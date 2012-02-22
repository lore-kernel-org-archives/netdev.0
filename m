From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: [PATCH] checkpatch: Add some --strict coding style checks
Date: Wed, 22 Feb 2012 10:46:14 +0100
Message-ID: <1329903974.4657.0.camel@jlt3.sipsolutions.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E77@saturn3.aculab.com>
	 (sfid-20120222_103559_848738_672B22CE)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>,
	Andy Whitcroft <apw@shadowen.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	andrei.emeltchenko.news@gmail.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E77@saturn3.aculab.com> (sfid-20120222_103559_848738_672B22CE)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-22 at 09:35 +0000, David Laight wrote:
> > 	if (!(func_a(x) &&
> > 		func_b(y)))
> > 		baz();
> 
> Gah - that is horrid for the 'preferred style'.
> A quick glance at the code puts both the func_b()
> and baz() calls as inside the if.

You forgot to read/quote the rest of Allan's email:

> Assuming my stupid mailer will screw up the indentation above, the 'a'
> in addr in the first example is meant to be immediately below the 'n'
> in nr, and the two 'f's in func_* are meant to be vertically lined up
> in the second example.

johannes
