From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mcs7830: Implement link state detection
Date: Sat, 02 Jun 2012 17:09:19 -0400 (EDT)
Message-ID: <20120602.170919.987778525333188042.davem@davemloft.net>
References: <201206012229.11530.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@lisas.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201206012229.11530.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Fri, 1 Jun 2012 22:29:08 +0200

> Add .status callback that detects link state changes.
> Tested with MCS7832CV-AA chip (9710:7830, identified as rev.C by the driver).
> Fixes https://bugzilla.kernel.org/show_bug.cgi?id=28532
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Applied.
