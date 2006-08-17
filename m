From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC][PATCH 0/75] pci_module_init to pci_register_driver	conversion
Date: Thu, 17 Aug 2006 08:43:45 -0400
Message-ID: <44E46481.6000408@garzik.org>
References: <20060817042634.0.CrzcY28443.28439.michal@ltg01-fedora.pl>	 <20060817055814.GA14950@kroah.com>  <44E46280.2020109@garzik.org> <1155818266.4494.59.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60586 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932188AbWHQMnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 08:43:49 -0400
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1155818266.4494.59.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
>> But it is most definitely not 2.6.18-rc material :)
> 
> that part of it isn't.. marking it deprecated so that people doing new
> code get a warning probably IS 2.6.18, the sooner that happens the
> better....

I disagree.  With all the cleanups going into 2.6.19, that would just 
introduce needless build noise into 2.6.18.

	Jeff



