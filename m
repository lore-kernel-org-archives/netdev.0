From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v4 1/9] pasemi_mac: Move the IRQ mapping from the PCI
 layer to the driver
Date: Tue, 08 May 2007 01:48:30 -0400
Message-ID: <46400F2E.7020807@garzik.org>
References: <20070508053500.358169000@localhost.localdomain> <20070508054721.GB14321@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54688 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967927AbXEHFsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:48:33 -0400
In-Reply-To: <20070508054721.GB14321@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> Fixes for ethernet IRQ mapping, to be done in the driver instead of in
> the platform setup code.
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

applied 1-9


