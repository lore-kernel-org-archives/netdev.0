From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 00/14] Bug Fixes in ENA driver.
Date: Fri, 27 Jan 2017 11:07:44 -0500 (EST)
Message-ID: <20170127.110744.1353435501002512276.davem@davemloft.net>
References: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        dwmw@amazon.com, zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com
To: netanel@annapurnalabs.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Netanel Belgazal <netanel@annapurnalabs.com>
Date: Fri, 27 Jan 2017 00:18:02 +0200

> Changes between V3 and V2:
> * Fix typos and correct alignment in commit messages.
> * use napi_complete_done() return value to determine when the napi
> handler needs to unmask the interrupts rather than implementing
> non standard solution.
> * Remove new features from this patchset and leave bug fixes only.
> * Give example in the commit message for kernel crashes.
> * Use BIT(x) instead of use the value explicitly.

This series does not apply cleanly to net-next, please respin.
