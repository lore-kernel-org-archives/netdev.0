From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] hyperv: Fix error return code in netvsc_init_buf()
Date: Wed, 23 Jul 2014 15:25:29 +0000
Message-ID: <cd173fe873c341d4b2796531c405d15d@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1406077235-29095-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "weiyj_lk@163.com" <weiyj_lk@163.com>,
	KY Srinivasan <kys@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-sn2-obe.ptr.o365filtering.com ([157.55.158.27]:41840 "EHLO
	na01-sn2-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757967AbaGWPZk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2014 11:25:40 -0400
In-Reply-To: <1406077235-29095-1-git-send-email-weiyj_lk@163.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: weiyj_lk@163.com [mailto:weiyj_lk@163.com]
> Sent: Tuesday, July 22, 2014 9:01 PM
> To: KY Srinivasan; Haiyang Zhang
> Cc: Wei Yongjun; devel@linuxdriverproject.org; netdev@vger.kernel.org
> Subject: [PATCH] hyperv: Fix error return code in netvsc_init_buf()
> 
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return -ENOMEM from the kalloc error handling
> case instead of 0.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>

Good catch.

Thanks,
- Haiyang
