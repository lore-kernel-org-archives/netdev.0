From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 PATCH 1/4] vxge: Fix a possible memory leak in
 vxge_hw_device_initialize().
Date: Thu, 08 Apr 2010 01:44:48 -0700 (PDT)
Message-ID: <20100408.014448.00691212.davem@davemloft.net>
References: <Pine.GSO.4.10.11004080441240.365-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa.Honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37623
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757004Ab0DHIop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 04:44:45 -0400
In-Reply-To: <Pine.GSO.4.10.11004080441240.365-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Thu, 8 Apr 2010 04:42:02 -0400 (EDT)

> - Fix a possible memory leak in vxge_hw_device_initialize(). Free hldev if
> vxge_hw_device_reg_addr_get() fails.
>  
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@exar.com>

Applied, thanks.
