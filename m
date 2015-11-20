From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 v3] dl2k: Implement suspend
Date: Fri, 20 Nov 2015 14:49:15 -0500 (EST)
Message-ID: <20151120.144915.392254535455888665.davem@davemloft.net>
References: <1447960386-3049-1-git-send-email-linux@rainbow-software.org>
	<1447960386-3049-3-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447960386-3049-3-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Thu, 19 Nov 2015 20:13:06 +0100

> Add suspend/resume support to dl2k driver.
> This requires RX/TX rings to be reset so split out the required
> functionality from alloc_list() into new rio_reset_ring().
> 
> Tested on Asus NX1101 (IP1000A) and D-Link DGE-550T (DL-2000).
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Applied to net-next.
