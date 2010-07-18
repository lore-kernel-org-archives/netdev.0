From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/1] qlcnic: fix pci resource leak
Date: Sun, 18 Jul 2010 14:52:09 -0700 (PDT)
Message-ID: <20100718.145209.85429631.davem@davemloft.net>
References: <1279352378-22692-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33850
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757345Ab0GRVvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 17:51:53 -0400
In-Reply-To: <1279352378-22692-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: amit.salecha@qlogic.com
Date: Sat, 17 Jul 2010 00:39:38 -0700

> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
> 
> pci_get_domain_bus_and_slot: caller must decrement the
> reference count by calling pci_dev_put().
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied, thanks.
