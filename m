From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/4] vxge: Allow driver load for all
 enumerated pci functions.
Date: Thu, 08 Apr 2010 01:48:36 -0700 (PDT)
Message-ID: <20100408.014836.265565796.davem@davemloft.net>
References: <Pine.GSO.4.10.11004080442170.365-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa.Honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57863
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751938Ab0DHIsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 04:48:33 -0400
In-Reply-To: <Pine.GSO.4.10.11004080442170.365-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Thu, 8 Apr 2010 04:43:37 -0400 (EDT)

> - Allow all instances of the driver be loaded when multiple pci functions are
> enumerated. The max_config_dev driver loadable option limits the driver
> load instances if required. The X3100's function configuration of single/multi
> function, SR and MR IOV allows the user to select the number of pci functions.
>  
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@exar.com>

Applied.
