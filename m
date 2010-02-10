From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-02-10
Date: Wed, 10 Feb 2010 12:25:40 -0800 (PST)
Message-ID: <20100210.122540.149553948.davem@davemloft.net>
References: <1265829337.19075.0.camel@jlt3.sipsolutions.net>
	<20100210.113658.137273026.davem@davemloft.net>
	<20100210201953.GC3286@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mb@bu3sch.de
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100210201953.GC3286@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 10 Feb 2010 15:19:54 -0500

> On Wed, Feb 10, 2010 at 11:36:58AM -0800, David Miller wrote:
>> From: Johannes Berg <johannes@sipsolutions.net>
>> Date: Wed, 10 Feb 2010 20:15:37 +0100
>> 
>> > It was intentional -- that sdev doesn't even have an irq member, but
>> > nobody ever noticed because of the wrong ifdef.
>> 
>> Ok, then this needs to be explained in the commit message.
> 
> OK...mind if I just revert the current version and ask Michael to
> resubmit with an appropriate changelog entry?

Have you pulled this tree into others already?  Why not
just pop out the commit and fix it's commit message, then
reapply?

Having the revert commit in there is really stupid just for this.
