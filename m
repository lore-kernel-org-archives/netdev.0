From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/fddi: Replace local marco with PCI standard
 macro
Date: Thu, 05 Dec 2013 23:44:20 -0500 (EST)
Message-ID: <20131205.234420.2000965496889063263.davem@davemloft.net>
References: <1386243482-32856-1-git-send-email-wangyijing@huawei.com>
	<alpine.LFD.2.10.1312052154190.1599@eddie.linux-mips.org>
	<52A13F34.2010403@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: macro@linux-mips.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, guohanjun@huawei.com
To: wangyijing@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958Ab3LFEoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 23:44:22 -0500
In-Reply-To: <52A13F34.2010403@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 6 Dec 2013 11:06:28 +0800

> On 2013/12/6 6:06, Maciej W. Rozycki wrote:
>> On Thu, 5 Dec 2013, Yijing Wang wrote:
>> 
>>> Replace local marco DFX_BUS_PCI with PCI standard marco
>>> dev_is_pci().
>> 
>>  Typos above: marco -> macro
> 
> Sorry for the mistake, David, should i need to resend this patch to fix this typo error?

You have to resubmit all of these conversions again because you posted
them before the net-next tree was even open for submissions.

So you might as well fix the typos etc. while doing so.
