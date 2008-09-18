From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][CORRECTED] atl2: add atl2 driver
Date: Thu, 18 Sep 2008 12:05:55 -0400
Message-ID: <48D27C63.10204@garzik.org>
References: <20080914195610.1fd9dab8@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44526 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754093AbYIRQGA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 12:06:00 -0400
In-Reply-To: <20080914195610.1fd9dab8@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> From: Chris Snook <csnook@redhat.com>
> 
> Driver for Atheros L2 10/100 network device. Includes necessary
> changes for Kconfig, Makefile, and pci_ids.h.
> 
> Signed-off-by: Chris Snook <csnook@redhat.com>
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> ---
> 
> Changed "Sighed-off-by" to "Signed-off-by" for Chris' entry.
> 
> If this file is too large for vger, the full patch may be obtained from
> ftp://ftp.hogchain.net/pub/linux/attansic/atlx/0001-atl2-add-atl2-driver.patch
> 
>  drivers/net/Kconfig       |   11 +
>  drivers/net/Makefile      |    1 +
>  drivers/net/atlx/Makefile |    2 +
>  drivers/net/atlx/atl2.c   | 3127 +++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/atlx/atl2.h   |  530 ++++++++
>  include/linux/pci_ids.h   |    1 +
>  6 files changed, 3672 insertions(+), 0 deletions(-)

applied


