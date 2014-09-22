From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] qlge: Fix compilation warning
Date: Mon, 22 Sep 2014 14:36:28 -0400 (EDT)
Message-ID: <20140922.143628.1929887462674847544.davem@davemloft.net>
References: <1411075645-21845-1-git-send-email-harish.patil@qlogic.com>
	<1411075645-21845-2-git-send-email-harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-GELinuxNICDev@qlogic.com,
	sudarsana.kalluru@qlogic.com
To: harish.patil@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906AbaIVSgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 14:36:31 -0400
In-Reply-To: <1411075645-21845-2-git-send-email-harish.patil@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>
Date: Thu, 18 Sep 2014 17:27:24 -0400

> From: Harish Patil <harish.patil@qlogic.com>
> 
> Signed-off-by: Harish Patil <harish.patil@qlogic.com>
> 
> Fix the below warning message:
> qlge_main.c:1754: warning: 'lbq_desc' may be used uninitialized in this function

Next time, put the build warning information before, not after, your signoff.
