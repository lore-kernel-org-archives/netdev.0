From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] Allow FW size upto 1MB, support for
 S25FL032P flash and misc. fixes
Date: Wed, 10 Sep 2014 14:02:58 -0700 (PDT)
Message-ID: <20140910.140258.1771266084894026474.davem@davemloft.net>
References: <1410351271-26428-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43351 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbaIJVC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 17:02:59 -0400
In-Reply-To: <1410351271-26428-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 10 Sep 2014 17:44:26 +0530

> This patch series adds support to allow FW size upto 1MB, support for S25FL032P
> flash. Fix t4_flash_erase_sectors to throw an error, when erase sector aren't in
> the flash and also warning message when adapters have flashes less than 2Mb.
> Adds device id of new adapter and removes device id of debug adapter.
> 
> The patches series is created against 'net-next' tree.
> And includes patches on cxgb4 driver and cxgb4vf driver.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Series applied, thanks.
