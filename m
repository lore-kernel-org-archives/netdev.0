From: David Miller <davem@davemloft.net>
Subject: Re: [rds-devel] [PATCH] rds: prevent BUG_ON triggering on
 congestion map updates
Date: Tue, 08 Mar 2011 10:52:23 -0800 (PST)
Message-ID: <20110308.105223.71117584.davem@davemloft.net>
References: <1299083302-5168-1-git-send-email-nhorman@tuxdriver.com>
	<20110307.122753.59686845.davem@davemloft.net>
	<1299530363-sup-8922@think>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, venkat.x.venkatsubra@oracle.com
To: chris.mason@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34467
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754007Ab1CHSvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 13:51:46 -0500
In-Reply-To: <1299530363-sup-8922@think>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Mason <chris.mason@oracle.com>
Date: Mon, 07 Mar 2011 15:41:04 -0500

> Excerpts from David Miller's message of 2011-03-07 15:27:53 -0500:
>> From: Neil Horman <nhorman@tuxdriver.com>
>> Date: Wed,  2 Mar 2011 11:28:22 -0500
>> 
>> > Recently had this bug halt reported to me:
>> 
>> Well, does anyone on the RDS team care about this bug fix at all?
>> 
>> Stuff like this should not sit for nearly a week without any reply
>> whatsoever.
>> 
> 
> The patch looks good to me, but I'm surprised we haven't seen it here.
> Venkat please take a look (link to the patch below)  Has it only been seen on ppc?
> 
> http://permalink.gmane.org/gmane.linux.network/187933

Can I get an ACK or something, _please_?
