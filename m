From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init)
 for Marvel 88E1116R PHYs
Date: Thu, 03 Apr 2014 11:14:01 -0400 (EDT)
Message-ID: <20140403.111401.1679730754008116799.davem@davemloft.net>
References: <533D0B09.9040602@ahsoftware.de>
	<533D207E.9020909@gmail.com>
	<533D790C.5000104@ahsoftware.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	michal.simek@xilinx.com, stable@vger.kernel.org
To: holler@ahsoftware.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533D790C.5000104@ahsoftware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Holler <holler@ahsoftware.de>
Date: Thu, 03 Apr 2014 17:06:52 +0200

> But don't suggest me (or insist on) a time consuming

Bisects are not time consuming, and help developers analyze your
issue tremendously.
