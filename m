From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/4] vxge: Pass correct number of VFs
 value to pci_sriov_enable().
Date: Thu, 08 Apr 2010 01:49:03 -0700 (PDT)
Message-ID: <20100408.014903.98172958.davem@davemloft.net>
References: <Pine.GSO.4.10.11004080443390.365-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa.Honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57866
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751403Ab0DHItA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 04:49:00 -0400
In-Reply-To: <Pine.GSO.4.10.11004080443390.365-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Thu, 8 Apr 2010 04:44:26 -0400 (EDT)

> -  max_config_dev loadable parameter is set to 0xFF by default. Pass correct
>    number of VFs value to pci_sriov_enable() if max_config_dev is set to its 
>    default value.
>  
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@exar.com>

Applied.
