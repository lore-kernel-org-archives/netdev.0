From: David Miller <davem@davemloft.net>
Subject: Re: patch "appletalk: move to staging" added to staging tree
Date: Mon, 31 Jan 2011 14:05:36 -0800 (PST)
Message-ID: <20110131.140536.245399102.davem@davemloft.net>
References: <12965099622238@site>
	<201101312255.39981.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, acme@ghostprotocols.net, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36342
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754276Ab1AaWFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 17:05:01 -0500
In-Reply-To: <201101312255.39981.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 31 Jan 2011 22:55:39 +0100

> On Monday 31 January 2011, gregkh@suse.de wrote:
>> 
>> This is a note to let you know that I've just added the patch titled
>> 
>>     appletalk: move to staging
>> 
>> to my staging git tree which can be found at
>>     git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-2.6.git
>> in the staging-next branch.
> 
> Actually, David Miller objected to this patch for good reasons, please
> revert it. One of the other patches removes the BKL in appletalk, so
> we should find a way to keep it.

Right.
