From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/52] net: fealnx: remove unnecessary pci_set_drvdata()
Date: Thu, 12 Sep 2013 03:36:06 -0400 (EDT)
Message-ID: <20130912.033606.1689936899104585741.davem@davemloft.net>
References: <000e01ceaf4c$90cde130$b269a390$%han@samsung.com>
	<20130912.012443.2294235053428746280.davem@davemloft.net>
	<000601ceaf7b$e8e7b2e0$bab718a0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602Ab3ILHgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 03:36:08 -0400
In-Reply-To: <000601ceaf7b$e8e7b2e0$bab718a0$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Thu, 12 Sep 2013 14:49:56 +0900

> On Thursday, September 12, 2013 2:25 PM, David Miller wrote:
>> On Thu, 12 Sep 2013 09:11:01 +0900, Jingoo Han wrote:
>> > Would you let know the reason not to add coding style fixes?
>> 
>> They should be made seperately so that the individual changes
>> can be reviewed more easily and without unnecessary unrelated
>> changes mixed in.
> 
> OK, I see. :-)
> Thank you for your answer.
> Then, I will send V2 patch soon.

Please do not submit such a huge patch series in the future.

Anything more than 16 patches at a time is not reasonable and
overloads reviewer's capacity to look at your changes.

Thank you.
