From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/14] e1000: fix ethtool reported bus type for older
 adapters
Date: Fri, 15 Dec 2006 09:34:28 -0500
Message-ID: <4582B274.9030709@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175452.3365.127.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55173 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752031AbWLOOea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 09:34:30 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1166175452.3365.127.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Subject: e1000: fix ethtool reported bus type for older adapters
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> For older adapters we know that they are of the PCI bus type, so we can
> just set this.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

ACK patches 1-2, 8-9


