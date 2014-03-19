From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bonding: ratelimit pr_warn()s in 802.3ad
 mode
Date: Wed, 19 Mar 2014 13:56:39 -0400 (EDT)
Message-ID: <20140319.135639.420097334293310042.davem@davemloft.net>
References: <1394988903-19099-1-git-send-email-vfalico@redhat.com>
	<20140319092300.GA17378@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbaCSR4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 13:56:41 -0400
In-Reply-To: <20140319092300.GA17378@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Wed, 19 Mar 2014 10:23:00 +0100

> On Sun, Mar 16, 2014 at 05:55:03PM +0100, Veaceslav Falico wrote:
>>Only ratelimit the ones that might spam, omiting the ones from
>>enslave/deslave.
>>
>>CC: Jay Vosburgh <fubar@us.ibm.com>
>>CC: Andy Gospodarek <andy@greyhouse.net>
>>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> 
> (sorry for the noise)
> 
> David, I've seen that this patch was applied to the tree - but either
> my
> mail broke, or did you stop sending notifications on accepted patches?
> 
> Thanks a lot, and sorry again for bugging.

I applied a bulk set of patches while purging my trash folder (which took
a long time and held me up from sending the replies out) and I accidently
missed this one.

Sorry about that.
