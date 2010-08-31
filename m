From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Mon, 30 Aug 2010 21:45:54 -0700 (PDT)
Message-ID: <20100830.214554.42790757.davem@davemloft.net>
References: <20100831125738.7f18610b.sfr@canb.auug.org.au>
	<1283224474.1759.30.camel@Joe-Laptop>
	<20100831135831.b0f124c4.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@suse.de, James.Bottomley@suse.de
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100831135831.b0f124c4.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 31 Aug 2010 13:58:31 +1000

> Yes, but there were comments on that and nothing since.  I think that
> James would like a minimal patch that just fixes the newly introduced
> warnings.

I think James is being overly difficult, and since it effects his code
you'd think that he might be a bit proactive and maybe spend the 5
freakin' minutes it might take to write the patch that matches his
exact requirements if they are so important.

Or, at least, I'm sure he could find enough time to sort it out in the
past month and a half don't you think?

I may be weird and a moron, but that's what I would do if my subsystem
had a build warning that was bugging people.
