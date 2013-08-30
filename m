From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 25/31] net: davinci_mdio: use dev_get_platdata()
Date: Fri, 30 Aug 2013 10:48:46 +0530
Message-ID: <52202B36.5060504@ti.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com> <004901cea53e$9ff3bf30$dfdb3d90$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:50255 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017Ab3H3FQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:16:23 -0400
In-Reply-To: <004901cea53e$9ff3bf30$dfdb3d90$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 30 August 2013 10:36 AM, Jingoo Han wrote:
> Use the wrapper function for retrieving the platform data instead of
> accessing dev->platform_data directly. This is a cosmetic change
> to make the code simpler and enhance the readability.
>
> Signed-off-by: Jingoo Han<jg1.han@samsung.com>
> ---
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
