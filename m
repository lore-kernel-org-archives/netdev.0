From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fix incorrect PFVF CMASK
Date: Thu, 10 Jan 2013 00:06:37 -0800 (PST)
Message-ID: <20130110.000637.2196290776660479479.davem@davemloft.net>
References: <1357753369-26471-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, dm@chelsio.com,
	abhishek@chelsio.com, jay@chelsio.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932564Ab3AJIGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 03:06:38 -0500
In-Reply-To: <1357753369-26471-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Wed,  9 Jan 2013 23:12:49 +0530

> With Hard-Wired firmware configuration it was incorrectly provisioning the VFs
> Channel Access Rights Mask.
> 
> Signed-off-by: Jay Hernandez <jay@chelsio.com>
> Signed-off-by: Vipul Pandya <vipul@chelsio.com>

Applied, thanks.
