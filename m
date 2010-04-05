From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/11] drivers/uwb: Rename dev_info to wdi
Date: Mon, 05 Apr 2010 14:51:44 -0700 (PDT)
Message-ID: <20100405.145144.207421561.davem@davemloft.net>
References: <20100304232928.2e45bdd1.akpm@linux-foundation.org>
	<6bd4d4dacf32631b72c3827a3b133a26e2e8b889.1270493677.git.joe@perches.com>
	<1270503858.31062.43.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, david.vrabel@csr.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59598
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756439Ab0DEVvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 17:51:42 -0400
In-Reply-To: <1270503858.31062.43.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 05 Apr 2010 14:44:18 -0700

> On Mon, 2010-04-05 at 12:05 -0700, Joe Perches wrote:
>> There is a macro called dev_info that prints struct device specific
>> information.  Having variables with the same name can be confusing and
>> prevents conversion of the macro to a function.
>> 
>> Rename the existing dev_info variables to something else in preparation
>> to converting the dev_info macro to a function.
> 
> http://patchwork.ozlabs.org/patch/49421/
> 
> This marked as RFC in patchwork.
> It's not intended to be.

Because I can't apply the entire set, I'd like someone else
to take this in since it's not really a networking specific
patch.
