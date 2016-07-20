From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] wan/fsl_ucc_hdlc: use module_platform_driver to
 simplify the code
Date: Wed, 20 Jul 2016 14:47:56 -0700 (PDT)
Message-ID: <20160720.144756.1830055477288190098.davem@davemloft.net>
References: <1468927516-32569-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: qiang.zhao@nxp.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55610 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755534AbcGTVsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 17:48:02 -0400
In-Reply-To: <1468927516-32569-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj_lk@163.com>
Date: Tue, 19 Jul 2016 11:25:16 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> module_platform_driver() makes the code simpler by eliminating
> boilerplate code.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
