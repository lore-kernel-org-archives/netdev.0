From: David Miller <davem@davemloft.net>
Subject: Re: [V4 PATCH 3/3] bond: service netpoll arp queue on master device
Date: Sun, 27 Feb 2011 20:12:13 -0800 (PST)
Message-ID: <20110227.201213.193724028.davem@davemloft.net>
References: <1298022215-21059-3-git-send-email-amwang@redhat.com>
	<20110227.161225.200373200.davem@davemloft.net>
	<4D6B1742.6030108@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, nhorman@redhat.com,
	herbert@gondor.hengli.com.au, nhorman@tuxdriver.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38781
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752168Ab1B1ELg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 23:11:36 -0500
In-Reply-To: <4D6B1742.6030108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 28 Feb 2011 11:32:18 +0800

> 于 2011年02月28日 08:12, David Miller 写道:
>> From: Amerigo Wang<amwang@redhat.com>
>> Date: Fri, 18 Feb 2011 17:43:34 +0800
>>
>>> Neil pointed out that we can't send ARP reply on behalf of slaves,
>>> we need to move the arp queue to their bond device.
>>>
>>> Signed-off-by: WANG Cong<amwang@redhat.com>
>>
>> Applied.
> 
> Oops! Just found that this one I sent was not a refreshed patch.
> Please discard this one, and use the one below, that is the
> correct one in my git tree and the one that I tested.

Done.
