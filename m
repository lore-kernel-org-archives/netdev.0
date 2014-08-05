From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4vf: Turn off SGE RX/TX Callback Timers
 and interrupts in PCI shutdown routine
Date: Tue, 05 Aug 2014 16:41:07 -0700 (PDT)
Message-ID: <20140805.164107.1171895481492920348.davem@davemloft.net>
References: <1407233488-17030-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60496 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbaHEXlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:41:08 -0400
In-Reply-To: <1407233488-17030-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue,  5 Aug 2014 15:41:28 +0530

> Need to turn off  SGE RX/TX Callback Timers & interrupt in cxgb4vf PCI Shutdown
> routine in order to prevent crashes during reboot/poweroff when traffic is
> running.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
