From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] qlcnic: Refactoring and enhancements for
 all adapters.
Date: Mon, 27 Jan 2014 15:24:33 -0800 (PST)
Message-ID: <20140127.152433.629611759956344780.davem@davemloft.net>
References: <cover.1390491376.git.himanshu.madhani@qlogic.com>
	<20140123.161437.1632835743136251770.davem@davemloft.net>
	<52E6D7E1.90204@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: himanshu.madhani@qlogic.com, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: zoltan.kiss@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491AbaA0XYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 18:24:36 -0500
In-Reply-To: <52E6D7E1.90204@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Mon, 27 Jan 2014 22:04:17 +0000

> On 24/01/14 00:14, David Miller wrote:
>> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
>> Date: Thu, 23 Jan 2014 17:18:27 -0500
>>
>>> This patch series contains following patches.
>>>
>>> o Enhanced debug data collection when we are in Tx-timeout situation.
>>> o Enhanced MSI-x vector calculation for defualt load path as well
>>>    as for TSS/RSS ring change path.
>>> o Refactored interrupt coalescing code for all adapters.
>>> o Refactored interrupt handling as well as cleanup of poll controller
>>>    code patch for all adapters.
>>> o changed rx_mac_learn type to boolean.
>>>
>>> Please apply to net-next.
>>
>> Series applied, thanks.
> 
> Not that I reject fame, but the commit message contains my name as
> sign-off, while I've never seen a bit of that code :)

Sorry about that.  What happens is that I build the merge commit
messages from a template, and I used a template for a previous
serious with your signoff by accident :-/
