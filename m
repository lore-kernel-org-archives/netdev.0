From: Ye Xiaolong <xiaolong.ye@intel.com>
Subject: Re: [lkp] [net]  af1fee9821:
 BUG:spinlock_trylock_failure_on_UP_on_CPU
Date: Tue, 8 Nov 2016 10:01:51 +0800
Message-ID: <20161108020151.GA16988@yexl-desktop>
References: <20161107022628.GA21529@yexl-desktop>
 <20161107093148.GA27001@lunn.ch>
 <20161107132714.GA10669@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
        "David S. Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
        lkp@01.org
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:41338 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751905AbcKHCCq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Nov 2016 21:02:46 -0500
Content-Disposition: inline
In-Reply-To: <20161107132714.GA10669@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07, Allan W. Nielsen wrote:
>Hi,
>
>I tried to get this "lkp" up and running, but I had some troubles gettting
>these scripts to work.

Hi, Allan

Could you tell us what troubles you have met when trying the "lkp qemu"
tool, it would be better if you could paste some log so we can help to
improve it.

Thanks,
Xiaolong

>
>But it seems like it can be reproduced using th eprovided config file, and qemu.
