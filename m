From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netxen: Fix link event handling.
Date: Thu, 06 Nov 2014 16:43:53 -0500 (EST)
Message-ID: <20141106.164353.894892101725132499.davem@davemloft.net>
References: <1415278731-26404-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mkubecek@suse.cz,
	Dept-GELinuxNICDev@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbaKFVnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 16:43:55 -0500
In-Reply-To: <1415278731-26404-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Thu, 6 Nov 2014 07:58:51 -0500

> o Poll for the link events only if firmware doesn't have capability
>   to notify the driver for the link events.
> 
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>

Applied, thanks.
