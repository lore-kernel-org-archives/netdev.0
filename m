From: David Miller <davem@davemloft.net>
Subject: Re: tg3:No interrupt was generated using MSI, switching to INTx
 mode. Please report this failure to the PCI maintainer and include system
 chipset information.
Date: Tue, 28 Oct 2008 12:04:19 -0700 (PDT)
Message-ID: <20081028.120419.252131562.davem@davemloft.net>
References: <1225191510.26840.6.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: donner@dbd-breitband.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43451
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751341AbYJ1TEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 15:04:42 -0400
In-Reply-To: <1225191510.26840.6.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Donner <donner@dbd-breitband.de>
Date: Tue, 28 Oct 2008 11:58:30 +0100

Please report networking problems to netdev@vger.kernel.org
(added to CC:)

Many networking developers do not read linux-kernel

> Hi @all,
> 
> we have installed a dual port Brodcam Gigabit Ethernet NIC, and get the
> following error in dmesg:
> 
> tg3: eth1 No interrupt was generated using MSI, switching to INTx mode.
> Please report this failure to the PCI maintainer and include system
> chipset information.
> 
> Who is responsible for this error message? We are using Kernel 2.6.21.1
> and the NIC Chipset is a Broadcom BCM5715CKPBG
> 
> Regards,
> 
> Marc
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
