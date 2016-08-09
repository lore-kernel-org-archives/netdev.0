From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Tue, 09 Aug 2016 12:10:10 -0700 (PDT)
Message-ID: <20160809.121010.539583047008259861.davem@davemloft.net>
References: <20160809030956.GL22974@cork>
	<16281.1470766891@famine>
	<20160809184057.GO22974@cork>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: jay.vosburgh@canonical.com, dingtianhong@huawei.com,
	andy@greyhouse.net, netdev@vger.kernel.org
To: joern@purestorage.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35292 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932209AbcHITKM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 15:10:12 -0400
Received: by mail-pa0-f68.google.com with SMTP id cf3so1371548pad.2
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 12:10:12 -0700 (PDT)
In-Reply-To: <20160809184057.GO22974@cork>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jörn Engel <joern@purestorage.com>
Date: Tue, 9 Aug 2016 11:40:57 -0700

> On Tue, Aug 09, 2016 at 11:21:31AM -0700, Jay Vosburgh wrote:
>> 	The balance-rr mode (as well as the -xor mode) is designed to
>> interoperate with a Cisco Etherchannel-style static link aggregation,
>> which requires all members to have the same MAC address for proper
>> function.
> 
> Linux was designed to be a terminal for dialup to a university in
> Helsinki, if memory serves.  Sometimes it is a good thing to work in
> ways the design never intended.

You're not addressing the issue Jay is trying to make you aware of
in a useful way.

You state that Jay doesn't want to help you, but your comment here
shows that you really aren't exactly participating in the most
positive manner either.
