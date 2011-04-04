From: Patrick McHardy <kaber@trash.net>
Subject: Re: connector: convert to synchronous netlink message processing
Date: Mon, 04 Apr 2011 14:47:39 +0200
Message-ID: <4D99BDEB.6000603@trash.net>
References: <4D90D5E8.4080002@trash.net> <20110330133913.GA9425@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51572 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab1DDMrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 08:47:49 -0400
In-Reply-To: <20110330133913.GA9425@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.03.2011 15:39, Evgeniy Polyakov wrote:
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

Thanks, I'll run some test just to be sure.

> Your patch looks very good and I definitely ack this :)

Thanks!



