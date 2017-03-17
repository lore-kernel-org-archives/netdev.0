From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] sunvnet: better connection management
Date: Thu, 16 Mar 2017 20:30:10 -0700 (PDT)
Message-ID: <20170316.203010.1792960724364202011.davem@davemloft.net>
References: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: shannon.nelson@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Tue, 14 Mar 2017 10:24:38 -0700

> These patches remove some problems in handling of carrier state
> with the ldmvsw vswitch, remove  an xoff misuse in sunvnet, and
> add stats for debug and tracking of point-to-point connections
> between the ldom VMs.
> 
> v2:
>  - added ldmvsw ndo_open to reset the LDC channel
>  - updated copyrights

Series applied, thanks Shannon.
