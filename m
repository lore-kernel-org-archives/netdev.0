From: David Vrabel <david.vrabel@csr.com>
Subject: Re: [PATCH 11/11] drivers/uwb: Rename dev_info to wdi
Date: Tue, 06 Apr 2010 13:42:58 +0100
Message-ID: <4BBB2C52.7080905@csr.com>
References: <20100304232928.2e45bdd1.akpm@linux-foundation.org>	<6bd4d4dacf32631b72c3827a3b133a26e2e8b889.1270493677.git.joe@perches.com>	<1270503858.31062.43.camel@Joe-Laptop.home> <20100405.145144.207421561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cluster-d.mailcontrol.com ([85.115.60.190]:40065 "EHLO
	cluster-d.mailcontrol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754426Ab0DFMqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 08:46:04 -0400
In-Reply-To: <20100405.145144.207421561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Mon, 05 Apr 2010 14:44:18 -0700
> 
>> On Mon, 2010-04-05 at 12:05 -0700, Joe Perches wrote:
>>> There is a macro called dev_info that prints struct device specific
>>> information.  Having variables with the same name can be confusing and
>>> prevents conversion of the macro to a function.
>>>
>>> Rename the existing dev_info variables to something else in preparation
>>> to converting the dev_info macro to a function.
>> http://patchwork.ozlabs.org/patch/49421/
>>
>> This marked as RFC in patchwork.
>> It's not intended to be.
> 
> Because I can't apply the entire set, I'd like someone else
> to take this in since it's not really a networking specific
> patch.

I've taken it.

David
-- 
David Vrabel, Senior Software Engineer, Drivers
CSR, Churchill House, Cambridge Business Park,  Tel: +44 (0)1223 692562
Cowley Road, Cambridge, CB4 0WZ                 http://www.csr.com/


Member of the CSR plc group of companies. CSR plc registered in England and Wales, registered number 4187346, registered office Churchill House, Cambridge Business Park, Cowley Road, Cambridge, CB4 0WZ, United Kingdom
