From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: ethernet: cpsw: drop IRQF_DISABLED
Date: Fri, 2 Aug 2013 14:36:45 +0530
Message-ID: <51FB76A5.8070103@ti.com>
References: <1375429450-25454-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:43891 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757601Ab3HBJEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 05:04:43 -0400
In-Reply-To: <1375429450-25454-1-git-send-email-balbi@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 02 August 2013 01:14 PM, Felipe Balbi wrote:
> IRQF_DISABLED is a no-op by now and should be
> removed.
>
> Signed-off-by: Felipe Balbi<balbi@ti.com>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
