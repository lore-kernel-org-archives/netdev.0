From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net 0/6] Trivial fixes for cxgb4
Date: Mon, 01 Sep 2014 23:01:29 -0700 (PDT)
Message-ID: <20140901.230129.985433194173937755.davem@davemloft.net>
References: <1409581500-11264-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbaIBGBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 02:01:30 -0400
In-Reply-To: <1409581500-11264-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon,  1 Sep 2014 19:54:54 +0530

> This patch series adds support to fix T5 adapter accessing T4 adapter registers,
> issue mbox command on correct mbox for physical function, avoid dumping write
> only registers, use correct length for adapter part number and support to detect
> and display firmware reported errors.
> 
> The patches series is created against 'net' tree.
> And includes patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.
> 
> Thanks
> 
> V2:
>    Added description for each patch as per David Miller's comment

Series applied, thanks.
