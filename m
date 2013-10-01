From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qlcnic: Fix SR-IOV configuration
Date: Tue, 01 Oct 2013 12:35:18 -0400 (EDT)
Message-ID: <20131001.123518.513375250498189793.davem@davemloft.net>
References: <1380608628-8391-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	Dept-HSGLinuxNICDev@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54703 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279Ab3JAQfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:35:19 -0400
In-Reply-To: <1380608628-8391-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Tue, 1 Oct 2013 02:23:48 -0400

> o Interface needs to be brought down and up while configuring SR-IOV.
>   Protect interface up/down using rtnl_lock()/rtnl_unlock()
> 
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>

Applied, thanks.
