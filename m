From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] bonding: make arp_ip_target parameter checks
 consistent with sysfs
Date: Thu, 29 Nov 2012 13:14:18 -0500 (EST)
Message-ID: <20121129.131418.2087045655456588072.davem@davemloft.net>
References: <1354121052-6263-1-git-send-email-nikolay@redhat.com>
	<1354188846-15577-1-git-send-email-nikolay@redhat.com>
	<13894.1354210749@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881Ab2K2SO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:14:28 -0500
In-Reply-To: <13894.1354210749@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Thu, 29 Nov 2012 09:39:09 -0800

> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>> The module can be loaded with arp_ip_target="255.255.255.255" which makes
>> it impossible to remove as the function in sysfs checks for that value,
>> so we make the parameter checks consistent with sysfs.
>>
>> v2: Fix formatting
>> v3: Make description text < 75 columns
>>
>>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied.

Thanks a lot everyone.
