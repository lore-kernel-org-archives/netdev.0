From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8169:Remove unnecessary phy reset for pcie nic
 when setting link spped.
Date: Thu, 10 Mar 2016 16:18:41 -0500 (EST)
Message-ID: <20160310.161841.1115097085022801181.davem@davemloft.net>
References: <1457427065-3699-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457427065-3699-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chunhao Lin <hau@realtek.com>
Date: Tue, 8 Mar 2016 16:51:05 +0800

> For pcie nic, after setting link speed and thers is no link  driver does not need
> to do phy reset untill link up.

"there's", "until"

> For some pcie nics, to do this will also reset phy speed down counter and prevent
> phy from auto speed down.

Please fix these typos and resubmit, thanks.
