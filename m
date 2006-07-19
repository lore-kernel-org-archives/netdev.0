From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: sun happymeal, little pci cleanup
Date: Tue, 18 Jul 2006 17:32:38 -0700 (PDT)
Message-ID: <20060718.173238.63509821.davem@davemloft.net>
References: <20060718235638.DF54BAE43C5@sunset.davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:65201
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932440AbWGSAcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 20:32:17 -0400
To: jirislaby@gmail.com
In-Reply-To: <20060718235638.DF54BAE43C5@sunset.davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jirislaby@gmail.com>
Date: Tue, 18 Jul 2006 16:56:38 -0700 (PDT)

> NET: sun happymeal, little pci cleanup
> 
> Use pci_register_driver instead of pci_module_init. Use PCI_DEVICE macro.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

Applied, thanks Jiri.
