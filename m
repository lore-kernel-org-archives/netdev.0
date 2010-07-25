From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 2/2] qlcnic: fix diag resource allocation
Date: Sun, 25 Jul 2010 16:36:12 -0700 (PDT)
Message-ID: <20100725.163612.226761694.davem@davemloft.net>
References: <1280032338-7002-1-git-send-email-amit.salecha@qlogic.com>
	<1280032338-7002-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	sony.chacko@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42557
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752664Ab0GYXfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jul 2010 19:35:55 -0400
In-Reply-To: <1280032338-7002-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Sat, 24 Jul 2010 21:32:18 -0700

> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> netif_device_attach missing from error path in qlcnic_diag_alloc_res
> 
> Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
