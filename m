From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] 68360enet: Remove Kconfig/Makefile references
Date: Sat, 16 Jul 2011 12:35:39 -0700 (PDT)
Message-ID: <20110716.123539.133129534295714698.davem@davemloft.net>
References: <1310844806-763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58078 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137Ab1GPTfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2011 15:35:43 -0400
In-Reply-To: <1310844806-763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 16 Jul 2011 12:33:26 -0700

> 68360enet.c no longer exists, and from the research, it appears that
> 68360enet.c became fec.c back in 2004.  The Kconfig and Makefile
> references were never cleaned up.  This patch removes this "dead"
> references.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
