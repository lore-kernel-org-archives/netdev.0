From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix 64 bit addressing support for GEM
Date: Thu, 26 Jan 2017 12:49:02 -0500 (EST)
Message-ID: <20170126.124902.1438876693756119777.davem@davemloft.net>
References: <1485442837-26598-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, harinikatakamlinux@gmail.com
To: rafalo@cadence.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485442837-26598-1-git-send-email-rafalo@cadence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafal Ozieblo <rafalo@cadence.com>
Date: Thu, 26 Jan 2017 15:00:37 +0000

> This patch adds support for 32 bit GEM in
> 64 bit system. It checks capability at runtime
> and uses appropriate buffer descriptor.
> 
> Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>

Please use a proper subsystem prefix in the Subject lines of your
patch submission, in this case it would be:

	[PATCH] macb: Fix 64-bit addressing support for GEM.

Thank you.
