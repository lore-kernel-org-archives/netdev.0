From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 24/31] net: davinci_emac: use dev_get_platdata()
Date: Fri, 30 Aug 2013 10:47:59 +0530
Message-ID: <52202B07.8000207@ti.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com> <004801cea53e$8a839e40$9f8adac0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:40363 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752498Ab3H3FPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 01:15:36 -0400
In-Reply-To: <004801cea53e$8a839e40$9f8adac0$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 30 August 2013 10:35 AM, Jingoo Han wrote:
>  From 829c7a4846b68ee49beb465db2caa1127cca38cc Mon Sep 17 00:00:00 2001
> From: Jingoo Han<jg1.han@samsung.com>
> Date: Fri, 30 Aug 2013 12:29:57 +0900
> Subject: [PATCH 24/31] net: davinci_emac: use dev_get_platdata()
>
> Use the wrapper function for retrieving the platform data instead of
> accessing dev->platform_data directly. This is a cosmetic change
> to make the code simpler and enhance the readability.
>
> Signed-off-by: Jingoo Han<jg1.han@samsung.com>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
