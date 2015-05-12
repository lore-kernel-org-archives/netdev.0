From: Ivan Mikhaylov <ivan@ru.ibm.com>
Subject: Re: [PATCH 1/2] ibm-emac: changes of emac_regs structure
 accordingly within driver emac_regs structure
Date: Tue, 12 May 2015 19:12:23 +0400
Message-ID: <20150512191223.583ebb03@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ben@decadent.org.uk, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From: Ivan Mikhaylov <ivan@ru.ibm.com>
>Date: Tue, 12 May 2015 17:11:44 +0400
>
>> In ibm_emac.c in ethtool size of emac structure which passing through
>> to driver is nailed down and not correlating with current emac_regs
>> structure.
>> 
>> Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>
>
>Please do not submit patches for two different projects as a single
>patch series.
>
>Thank you.

Dave, okay but if they're dependant on each other? 
Need I re-submit two patches as separate without series in subject?

Thanks.
