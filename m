From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 17/11]Optimize the upload speed for PPP connection.
Date: Tue, 17 Nov 2009 01:22:48 -0800 (PST)
Message-ID: <20091117.012248.86306050.davem@davemloft.net>
References: <faf197be196ee.196eefaf197be@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	william.allen.simpson@gmail.com
To: huananhu@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33321
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752771AbZKQJWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 04:22:32 -0500
In-Reply-To: <faf197be196ee.196eefaf197be@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fangxiaozhi 00110321 <huananhu@huawei.com>
Date: Tue, 17 Nov 2009 17:19:02 +0800

> From: fangxiaozhi <huananhu@huawei.com>
> 1. This patch is based on the kernel of 2.6.32-rc4 
> 2. In this patch, we enlarge the out buffer size to optimize the upload speed for the ppp connection. Then it can support the upload of HSUPA data cards.
> Signed-off-by: fangxiaozhi <huananhu@huawei.com>

Your patch is broken, please don't wate my time like this.

+ git apply --check --whitespace=error-all diff
error: patch failed: drivers/net/ppp_async.c:36
error: drivers/net/ppp_async.c: patch does not apply
