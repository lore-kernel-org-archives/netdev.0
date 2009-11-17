From: Franko Fang <huananhu@huawei.com>
Subject: Re: [PATCH 1/5]net: PPP buffer too small for higher speed connections
Date: Tue, 17 Nov 2009 20:04:10 +0800
Message-ID: <00e801ca677e$122c8c10$76900b0a@china.huawei.com>
References: <fb8cc3511cffa.1cffafb8cc351@huawei.com>
 <20091117.040234.245024359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	william.allen.simpson@gmail.com, jarkao2@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:40348 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754978AbZKQMEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 07:04:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, that's great.

Thanks very much for your help.
----- Original Message ----- 
From: "David Miller" <davem@davemloft.net>
To: <huananhu@huawei.com>
Cc: <netdev@vger.kernel.org>; <linux-kernel@vger.kernel.org>; <william.allen.simpson@gmail.com>; <jarkao2@gmail.com>
Sent: Tuesday, November 17, 2009 8:02 PM
Subject: Re: [PATCH 1/5]net: PPP buffer too small for higher speed connections


> From: fangxiaozhi 00110321 <huananhu@huawei.com>
> Date: Tue, 17 Nov 2009 19:59:05 +0800
> 
>> From: fangxiaozhi <huananhu@huawei.com>
>> 1. This patch is based on the kernel of 2.6.32-rc7 
>> 2. In this patch, we enlarge the out buffer size to optimize the upload speed for the ppp connection. Then it can support the upload of HSUPA data cards.
>> Signed-off-by: fangxiaozhi <huananhu@huawei.com>
> 
> Applied to net-next-2.6, thanks.
