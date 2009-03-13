From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.30 1/2] gianfar: remove gianfar_mii.c
Date: Fri, 13 Mar 2009 12:05:47 -0700 (PDT)
Message-ID: <20090313.120547.209883252.davem@davemloft.net>
References: <1236725908-8943-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751370AbZCMTGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 15:06:00 -0400
In-Reply-To: <1236725908-8943-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 10 Mar 2009 17:58:27 -0500

>     netdev: Merge UCC and gianfar MDIO bus drivers
> 
> left out the deletion of gianfar_mii.c.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied, this was likely caused by me when I added that
patch :-)

Thanks.
