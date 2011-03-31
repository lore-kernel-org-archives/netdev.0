From: David Miller <davem@davemloft.net>
Subject: Re: connector: convert to synchronous netlink message processing
Date: Wed, 30 Mar 2011 17:15:03 -0700 (PDT)
Message-ID: <20110330.171503.124058845.davem@davemloft.net>
References: <4D90D5E8.4080002@trash.net>
	<20110330133913.GA9425@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34360
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756566Ab1CaAPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 20:15:43 -0400
In-Reply-To: <20110330133913.GA9425@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Wed, 30 Mar 2011 17:39:13 +0400

> Hi Patrick
> 
> On Mon, Mar 28, 2011 at 08:39:36PM +0200, Patrick McHardy (kaber@trash.net) wrote:
>> This patch fixes up connector to work properly with the recent
>> netlink changes that require synchronous netlink message processing.
>> 
>> The patch is so far only compile tested since I'm still looking
>> for a good way to test it. If you could point me to some software
>> using the proc events that would be appreciated.
> 
> There is test module in Documentation/connector/ and/or samples/ which I
> used for tests. It was quite for a while when it was used last time
> though.
> 
> Your patch looks very good and I definitely ack this :)

Applied, if there are some bugs spotted, please just send the fixes
as follow-on patches.

Thanks.
