From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lib/Makefile: remove CONFIG_AVERAGE build rule
Date: Tue, 25 Aug 2015 17:21:43 -0700 (PDT)
Message-ID: <20150825.172143.2032613882553917093.davem@davemloft.net>
References: <1440151514-5796-1-git-send-email-valentinrothberg@gmail.com>
	<1440152003.2107.12.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: valentinrothberg@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440152003.2107.12.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 21 Aug 2015 12:13:23 +0200

> On Fri, 2015-08-21 at 10:05 +0000, Valentin Rothberg wrote:
>> The Kconfig option AVERAGE and its implementation has been removed by
>> commit f4e774f55fe0 ("average: remove out-of-line implementation").
>> Remove the dead build rule in lib/Makefile.
> 
> D'oh, sorry about that.
> 
> Reviewed-by: Johannes Berg <johannes@sipsolutions.net>
> 
> [reproducing patch in full for netdev]

The full patch needs to be resubmitted to netdev so that it gets
queued up in patchwork, thanks.
