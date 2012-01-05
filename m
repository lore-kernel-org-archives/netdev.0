From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xgmac: cleanups
Date: Thu, 05 Jan 2012 13:23:35 -0500 (EST)
Message-ID: <20120105.132335.1243032496063405675.davem@davemloft.net>
References: <20120104150116.2174467d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rob.herring@calxeda.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757464Ab2AESXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:23:39 -0500
In-Reply-To: <20120104150116.2174467d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 4 Jan 2012 15:01:16 -0800

> Make local function static, make ethtool_ops const.
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
