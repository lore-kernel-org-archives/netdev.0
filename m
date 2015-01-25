From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] mlx4: Fix and enhance the device reset
 flow
Date: Sat, 24 Jan 2015 23:31:24 -0800 (PST)
Message-ID: <20150124.233124.2121045040937058885.davem@davemloft.net>
References: <1421851557-12084-1-git-send-email-ogerlitz@mellanox.com>
	<54C103B2.2090406@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com,
	talal@mellanox.com, roland@kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60515 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbbAYHbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 02:31:25 -0500
In-Reply-To: <54C103B2.2090406@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 22 Jan 2015 16:05:38 +0200

> On 1/21/2015 4:45 PM, Or Gerlitz wrote:
>> This series from Yishai Hadas fixes the device reset flow and adds
>> SRIOV support.
>>
>> Reset flows are required whenever a device experiences errors, is
>> unresponsive,
>> or is not in a deterministic state. In such cases, the driver is
>> expected to
>> reset the HW and continue operation. When SRIOV is enabled, these
>> requirements
>> apply both to PF and VF devices.
> 
> So we spotted some problem in the SRIOV flow and prefer to fix it in a
> V1, which will be sent next week, please don't take this one.

Ok, I'll toss this series and wait for the new version.  Thanks.
