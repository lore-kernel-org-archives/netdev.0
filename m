From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] r8152: adjust runtime suspend/resume
Date: Tue, 13 Jun 2017 13:01:54 -0400 (EDT)
Message-ID: <20170613.130154.2119986704513730261.davem@davemloft.net>
References: <1394712342-15778-272-Taiwan-albertk@realtek.com>
        <1394712342-15778-275-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-275-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 13 Jun 2017 15:14:38 +0800

> v2:
> For #1, replace GFP_KERNEL with GFP_NOIO for usb_submit_urb().
> 
> v1:
> Improve the flow about runtime suspend/resume and make the code
> easy to read.

Series applied.
