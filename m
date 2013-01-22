From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/33] net: Convert to devm_ioremap_resource()
Date: Tue, 22 Jan 2013 14:08:03 -0500 (EST)
Message-ID: <20130122.140803.575298725595555169.davem@davemloft.net>
References: <20130121.152913.1377695352860141642.davem@davemloft.net>
	<20130122065629.GA14523@avionic-0098.adnet.avionic-design.de>
	<201301221303.06785.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thierry.reding@avionic-design.de, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	w.sang@pengutronix.de, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899Ab3AVTIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 14:08:05 -0500
In-Reply-To: <201301221303.06785.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 22 Jan 2013 13:03:06 +0000

> On Tuesday 22 January 2013, Thierry Reding wrote:
>> I planned to do so initially, but that yielded a Cc list of 156 people
>> and mailing lists, which I thought wasn't going to go down so well
>> either. In general I like Cc'ing everyone concerned on all patches of
>> the series, specifically for reasons of context. Some people have been
>> annoyed when I did so. Still, for small series where only a few dozen
>> people are concerned that seems to me to be the best way. But 156 email
>> addresses is a different story.
>> 
>> Either you add to many people or you don't add enough. Where do we draw
>> the line?
> 
> I've had the same problem a couple of times. The best compromise seems
> to be to Cc only the top-level subsystem maintainers and mailing lists
> on the first email.

CC:'ing individuals is pointless, CC: only the subsystem lists in
question, the maintainers had better be reading those lists.
