From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Remove unnecessary condition check in phy
Date: Mon, 07 Apr 2014 20:55:39 -0400 (EDT)
Message-ID: <20140407.205539.1839816319052167194.davem@davemloft.net>
References: <533FB108.6010508@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: kumaran.4353@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756059AbaDHAzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 20:55:42 -0400
In-Reply-To: <533FB108.6010508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakumaran Kannan <kumaran.4353@gmail.com>
Date: Sat, 05 Apr 2014 13:00:16 +0530

> This condition check makes no difference in the code flow since 3.10
> 
> Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>

This patch doesn't apply cleanly to the current tree.

It's because your email client corrupted the patch, changing
TAB characters into spaces amongst other things.

Also your subject line is not properly formed.  It should
state the subsystem after the closing bracket, followed
by ": " then the top-level description of your change.
