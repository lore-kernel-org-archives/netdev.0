From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] cpsw: cpts: enable HWTSTAMP_FILTER_PTP_V1_L4_EVENT filter
Date: Thu, 8 Jun 2017 11:40:44 -0500
Message-ID: <ea451242-46f4-5d61-a157-2dfb6b86f684@ti.com>
References: <20170605232108.13453-1-grygorii.strashko@ti.com>
 <20170608.095233.1595372713471104187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <nsekhar@ti.com>,
        <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608.095233.1595372713471104187.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On 06/08/2017 08:52 AM, David Miller wrote:
> 
> These two patches do not apply cleanly to my net GIT tree, please respin.
> 

I did it on top of net-next as there some conflicts,
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git

I've just re-checked and both can be applied with no issues on top of 
net-next.

Sorry for inconvenience.

-- 
regards,
-grygorii
