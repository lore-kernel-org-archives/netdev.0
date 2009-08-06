From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: smsc911x: switch to new dev_pm_ops
Date: Wed, 05 Aug 2009 20:29:22 -0700 (PDT)
Message-ID: <20090805.202922.241102337.davem@davemloft.net>
References: <1249496971-9019-3-git-send-email-daniel@caiaq.de>
	<1249496971-9019-4-git-send-email-daniel@caiaq.de>
	<1249496971-9019-5-git-send-email-daniel@caiaq.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	steve.glendinning@smsc.com, netdev@vger.kernel.org
To: daniel@caiaq.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753982AbZHFD3O@vger.kernel.org>
In-Reply-To: <1249496971-9019-5-git-send-email-daniel@caiaq.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Mack <daniel@caiaq.de>
Date: Wed,  5 Aug 2009 20:29:31 +0200

> Hibernation is unsupported for now, which meets the actual
> implementation in the driver. For free/thaw, the chip's D2 state should
> be entered.
> 
> Signed-off-by: Daniel Mack <daniel@caiaq.de>

Steve, if it looks good to you I can toss this into net-next-2.6

Just let me know.
