From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [RFC][PATCH 50/75] net: drivers/net/wan/pci200syn.c pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 21:30:19 +0200
Message-ID: <m3psez5fec.fsf@defiant.localdomain>
References: <20060817132854.50.mHRHNx4920.3636.michal@euridica.enternet.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:42683 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1751258AbWHQTa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 15:30:26 -0400
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
In-Reply-To: <20060817132854.50.mHRHNx4920.3636.michal@euridica.enternet.net.pl> (Michal Piotrowski's message of "Thu, 17 Aug 2006 13:28:54 +0000")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Piotrowski <michal.k.k.piotrowski@gmail.com> writes:

> +++ linux-work2/drivers/net/wan/wanxl.c
> +++ linux-work2/drivers/net/wan/pci200syn.c

> -	return pci_module_init(&pci200_pci_driver);
> +	return pci_register_driver(&pci200_pci_driver);

Ok. Rozumiem, ze Jeff zrobi to w jednym, duzym batchu?
-- 
Krzysztof Halasa
