From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [RFC][PATCH 0/75] pci_module_init to pci_register_driver
	conversion
Date: Thu, 17 Aug 2006 14:37:46 +0200
Message-ID: <1155818266.4494.59.camel@laptopd505.fenrus.org>
References: <20060817042634.0.CrzcY28443.28439.michal@ltg01-fedora.pl>
	 <20060817055814.GA14950@kroah.com>  <44E46280.2020109@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:57571 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S932358AbWHQMiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 08:38:15 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44E46280.2020109@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> But it is most definitely not 2.6.18-rc material :)

that part of it isn't.. marking it deprecated so that people doing new
code get a warning probably IS 2.6.18, the sooner that happens the
better....



-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com

