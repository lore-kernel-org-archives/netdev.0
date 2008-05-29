From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IRDA: Do cleanup for dma
Date: Thu, 29 May 2008 03:34:42 -0700 (PDT)
Message-ID: <20080529.033442.175635712.davem@davemloft.net>
References: <48365CBF.4080502@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54582
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751211AbYE2Keq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 06:34:46 -0400
In-Reply-To: <48365CBF.4080502@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 23 May 2008 13:57:19 +0800

> 1. dma should be freed when dma2 request fail.
> 2. dma2 should be freed too when device close.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Jeff, did you get this or would you like me to pick
it up directly?

Thanks.
