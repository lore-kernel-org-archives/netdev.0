From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] qlcnic: Bug fixes
Date: Tue, 14 Oct 2014 17:06:08 -0400 (EDT)
Message-ID: <20141014.170608.171780525800644042.davem@davemloft.net>
References: <1413286906-14220-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932416AbaJNVGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 17:06:10 -0400
In-Reply-To: <1413286906-14220-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Tue, 14 Oct 2014 07:41:44 -0400

> This series fixes following issues.
> 
> * We were programming maximum number of arguments supported by
>   adapter instead of required in a command.
> * Destroy tx command requires three arguments instead of two.
> 
> Please apply these patches to net.

Series applied, thanks.
