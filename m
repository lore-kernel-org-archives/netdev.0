From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: xilinx: Do not use axienet on PPC
Date: Thu, 10 Jan 2013 14:38:01 -0800 (PST)
Message-ID: <20130110.143801.420264294426880465.davem@davemloft.net>
References: <1357837123-18996-1-git-send-email-michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michal.simek@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34547 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614Ab3AJWiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:38:02 -0500
In-Reply-To: <1357837123-18996-1-git-send-email-michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Simek <michal.simek@xilinx.com>
Date: Thu, 10 Jan 2013 17:58:42 +0100

> Axi ethernet can't be used on PPC because it is
> little endian IP and PPC is big endian.
> This system can't be designed.
> 
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

Applied.
