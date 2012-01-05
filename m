From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3" make ethtool ops const
Date: Thu, 05 Jan 2012 13:23:22 -0500 (EST)
Message-ID: <20120105.132322.2015739074067106029.davem@davemloft.net>
References: <20120104135813.06af6984@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756646Ab2AESXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:23:25 -0500
In-Reply-To: <20120104135813.06af6984@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 4 Jan 2012 13:58:13 -0800

> All tables of function pointers should be const to make hacks
> more difficult. Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
