From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] net: mvpp2: Assorted fixes
Date: Tue, 22 Jul 2014 13:16:39 -0700 (PDT)
Message-ID: <20140722.131639.1180592286226896307.davem@davemloft.net>
References: <1405961296-5846-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<20140721.202749.913689946944612851.davem@davemloft.net>
	<20140722144519.GA682@arch.cereza>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jason@lakedaemon.net, mw@semihalf.com,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, tawfik@marvell.com,
	alior@marvell.com
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756345AbaGVUQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 16:16:42 -0400
In-Reply-To: <20140722144519.GA682@arch.cereza>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date: Tue, 22 Jul 2014 11:45:19 -0300

> On 21 Jul 08:27 PM, David Miller wrote:
>> From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
>> Date: Mon, 21 Jul 2014 13:48:10 -0300
>> 
>> > This patchset contains a set of fixes for issues found while doing some
>> > more intensive tests on the recently accepted mvpp2 ethernet driver.
>> > 
>> > David: if we are still in time, we'd like to get the driver fixes merged
>> > for v3.17-rc1.
>> > 
>> > For the devicetree changes, it's already too late for that, since Jason
>> > Cooper has already posted the PRs for v3.17. I'll re-post them when
>> > v3.17-rc1 is released.
>> > 
>> > As usual, feedback is welcome.
>> 
>> This series does not apply to the 'net' tree at all, please respin
>> and resubmit.
> 
> This series applies on net-next.
> 
> Sorry for not mentioning it,

They are bonafide bug fixes, therefore should be targetted at 'net'.
