From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/4] add meminfo, bist status and misc. fixes
Date: Tue, 04 Aug 2015 01:25:27 -0700 (PDT)
Message-ID: <20150804.012527.1846602799326607390.davem@davemloft.net>
References: <1438679180-25930-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755110AbbHDIZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 04:25:30 -0400
In-Reply-To: <1438679180-25930-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue,  4 Aug 2015 14:36:16 +0530

> This patch series adds the following.
> Add support to dump memory address range of various hw modules
> Add support to dump edc bist status during ecc error
> Read correct bits of who am i register for T6 adapter
> and update T6 register range
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 and cxgb4vf driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.
> 
> Thanks
> 
> V2: PATCH 3/4 ("cxgb4/cxgb4vf: read the correct bits of PL Who Am I
>     register") Fix switch statement in get_chip_type() and some more style
>     fixes based on review comment by Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Series applied... although you really need to fix the time and date
on your computer.
