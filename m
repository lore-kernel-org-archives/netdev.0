From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cpsw: cpts: enable HWTSTAMP_FILTER_PTP_V1_L4_EVENT
 filter
Date: Thu, 08 Jun 2017 14:10:10 -0400 (EDT)
Message-ID: <20170608.141010.1768472832680101362.davem@davemloft.net>
References: <20170605232108.13453-1-grygorii.strashko@ti.com>
        <20170608.095233.1595372713471104187.davem@davemloft.net>
        <ea451242-46f4-5d61-a157-2dfb6b86f684@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsekhar@ti.com,
        linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ea451242-46f4-5d61-a157-2dfb6b86f684@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Thu, 8 Jun 2017 11:40:44 -0500

> Hi David,
> 
> On 06/08/2017 08:52 AM, David Miller wrote:
>> These two patches do not apply cleanly to my net GIT tree, please
>> respin.
>> 
> 
> I did it on top of net-next as there some conflicts,
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
> 
> I've just re-checked and both can be applied with no issues on top of
> net-next.
> 
> Sorry for inconvenience.

You should mention explicitly the tree your patches are targetting
in your Subject line in order to avoid this problem, like

Subject: [PATCH net-next] ...

Please resubmit your patches with proper Subject lines.

Thank you.
