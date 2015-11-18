From: Jason Gerard DeRose <jason@system76.com>
Subject: Re: [PATCH] ethernet/atheros/alx: add Killer E2400 device ID
Date: Wed, 18 Nov 2015 14:48:41 -0700
Message-ID: <564CF239.9030309@system76.com>
References: <1447809667-9454-1-git-send-email-jason@system76.com>
 <20151118.150642.1281703908211053053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benpope81@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.system76.com ([38.75.196.72]:42520 "EHLO mail.system76.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757173AbbKRVsr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 16:48:47 -0500
In-Reply-To: <20151118.150642.1281703908211053053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2015 01:06 PM, David Miller wrote:
> From: Jason Gerard DeRose <jason@system76.com>
> Date: Tue, 17 Nov 2015 18:21:07 -0700
>
>> From: Ben Pope <benpope81@gmail.com>
>>
>> This patch adds the PCI device ID (0xe0a1) and alx_pci_tbl entry for the
>> Killer E2400 Ethernet controller, modeled after the Killer E2200
>> controller support (0xe091) already present in the alx driver.
>>
>> This patch was originally authored by Ben Pope, but it got held up by
>> issues in the commit message, so I'm resubmitting it on his behalf.
>>
>> I've extensively used a kernel with this patch on a System76 serw9
>> laptop and am quite confident it works well (at least on the hardware I
>> have available for testing).
>>
>> Note that as a favor to System76, Ubuntu has been carrying this as a
>> sauce patch in their 4.2 based Wily kernel, which presumably has given
>> it real-world testing on other E2400 equipped hardware (I don't know of
>> any Ubuntu kernel bugs filed about it):
>>
>> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1498633
>>
>> Signed-off-by: Jason Gerard DeRose <jason@system76.com>
>
> Applied.

Much thanks!
