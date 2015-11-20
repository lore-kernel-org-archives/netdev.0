From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] dl2k: Reorder and cleanup initialization
Date: Fri, 20 Nov 2015 14:49:09 -0500 (EST)
Message-ID: <20151120.144909.1365193180024055997.davem@davemloft.net>
References: <1447960386-3049-1-git-send-email-linux@rainbow-software.org>
	<1447960386-3049-2-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447960386-3049-2-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Thu, 19 Nov 2015 20:13:05 +0100

> Move HW init and stop into separate functions.
> Request IRQ only after the HW has been reset (so interrupts are
> disabled and no stale interrupts are pending).
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Applied to net-next.
