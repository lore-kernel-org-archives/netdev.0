From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] net: mvpp2: Assorted fixes
Date: Tue, 22 Jul 2014 17:41:53 -0700 (PDT)
Message-ID: <20140722.174153.413669013449137654.davem@davemloft.net>
References: <20140722.131639.1180592286226896307.davem@davemloft.net>
	<20140723002916.67a0bb3c@free-electrons.com>
	<20140722232004.GA7838@arch.cereza>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jason@lakedaemon.net,
	mw@semihalf.com, gregory.clement@free-electrons.com,
	tawfik@marvell.com, alior@marvell.com
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbaGWAl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 20:41:57 -0400
In-Reply-To: <20140722232004.GA7838@arch.cereza>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date: Tue, 22 Jul 2014 20:20:04 -0300

> On 23 Jul 12:29 AM, Thomas Petazzoni wrote:
>> On Tue, 22 Jul 2014 13:16:39 -0700 (PDT), David Miller wrote:
>> 
>> > >> This series does not apply to the 'net' tree at all, please respin
>> > >> and resubmit.
>> > > 
>> > > This series applies on net-next.
>> > > 
>> > > Sorry for not mentioning it,
>> > 
>> > They are bonafide bug fixes, therefore should be targetted at 'net'.
>> 
>> Except that I believe they are fixes for a driver which itself is in
>> net-next, i.e scheduled for 3.17.
>> 
> 
> That's right. These are fixes for the new mvpp2 driver, which is only
> in net-next.

Ok, I queued them back up, thanks for the clarification.
