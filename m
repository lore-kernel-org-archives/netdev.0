From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] make ethtool_ops const
Date: Thu, 05 Jan 2012 13:23:28 -0500 (EST)
Message-ID: <20120105.132328.1647628535623391712.davem@davemloft.net>
References: <20120104145949.53ab334c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756693Ab2AESXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:23:31 -0500
In-Reply-To: <20120104145949.53ab334c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 4 Jan 2012 14:59:49 -0800

> Auditing all usage of ethtool_ops found several drivers that
> are not declaring the struct const when it should be.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
