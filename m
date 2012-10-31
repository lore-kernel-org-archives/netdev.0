From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] qla3xxx: use module_pci_driver to simplify the
 code
Date: Wed, 31 Oct 2012 13:36:08 -0400 (EDT)
Message-ID: <20121031.133608.2289101772589469673.davem@davemloft.net>
References: <CAPgLHd_Xu7TKZ_mqQ2r7A2GVCo+Us6kEggHc5d+hhg4Hh6cukA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jitendra.kalsaria@qlogic.com, ron.mercer@qlogic.com,
	yongjun_wei@trendmicro.com.cn, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965635Ab2JaRgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 13:36:12 -0400
In-Reply-To: <CAPgLHd_Xu7TKZ_mqQ2r7A2GVCo+Us6kEggHc5d+hhg4Hh6cukA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Fri, 26 Oct 2012 23:02:30 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Use the module_pci_driver() macro to make the code simpler
> by eliminating module_init and module_exit calls.
> 
> dpatch engine is used to auto generate this patch.
> (https://github.com/weiyj/dpatch)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
