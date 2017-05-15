From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 0/2] ldmvsw: port removal stability
Date: Mon, 15 May 2017 15:36:46 -0400 (EDT)
Message-ID: <20170515.153646.1717852985305748981.davem@redhat.com>
References: <1494870668-65047-1-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: shannon.nelson@oracle.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1494870668-65047-1-git-send-email-shannon.nelson@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Mon, 15 May 2017 10:51:06 -0700

> Under heavy reboot stress testing we found a couple of timing issues
> when removing the device that could cause the kernel great heartburn,
> addressed by these two patches.

These are pretty legit bug fixes so I've applied this series to net,
thanks.
