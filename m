From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] atm: eni: use DEFINE_PCI_DEVICE_TABLE macro
Date: Thu, 28 Nov 2013 15:48:39 -0500 (EST)
Message-ID: <20131128.154839.1344104104193014015.davem@davemloft.net>
References: <004501ceebeb$27dcd970$77968c50$%han@samsung.com>
	<005701ceebf3$dc4ae840$94e0b8c0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, romieu@fr.zoreil.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045Ab3K1Usn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 15:48:43 -0500
In-Reply-To: <005701ceebf3$dc4ae840$94e0b8c0$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Thu, 28 Nov 2013 13:39:44 +0900

> On Thursday, November 28, 2013 12:37 PM, Jingoo Han wrote:
>> 
>> This macro is used to create a struct pci_device_id array.
>> 
>> Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> 
> Please, ignore these patches.
> According to the Greg Kroah-Hartman, 
 ...

Ok, but it was also not appropriate to submit these patches because the
net-next tree is not open yet.

Thank you.
