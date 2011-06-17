From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: Remove casts of void *
Date: Fri, 17 Jun 2011 00:54:43 -0400 (EDT)
Message-ID: <20110617.005443.124861918568831869.davem@davemloft.net>
References: <d010144f11f9165670ac0c9e3559bf5e3191ff28.1308017857.git.joe@perches.com>
	<20110616.232344.2285390268187937319.davem@davemloft.net>
	<1308286320.12072.25.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, geert@linux-m68k.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061Ab1FQEzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 00:55:49 -0400
In-Reply-To: <1308286320.12072.25.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 16 Jun 2011 21:52:00 -0700

> On Thu, 2011-06-16 at 23:23 -0400, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Mon, 13 Jun 2011 19:21:26 -0700
>> > Unnecessary casts of void * clutter the code.
>> > Signed-off-by: Joe Perches <joe@perches.com>
>> Applied.
> 
> Hey David.
> 
> The equivalent drivers/net patch is marked "changes requested".
> I think that's not true as I only saw acks.

You were asked to modify the logic of your changes in one hunk
and even provided the RFC patch, please integrate that RFC patch
into your patch and resubmit.
