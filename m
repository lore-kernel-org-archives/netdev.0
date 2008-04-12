From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ehea: Fix DLPAR memory add support
Date: Sat, 12 Apr 2008 04:49:53 -0400
Message-ID: <480077B1.3010804@garzik.org>
References: <200804041504.54130.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Hannes Hering <hering2@de.ibm.com>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41445 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756754AbYDLIuA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 04:50:00 -0400
In-Reply-To: <200804041504.54130.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Klein wrote:
> This patch fixes two weaknesses in send/receive packet handling which may
> lead to kernel panics during DLPAR memory add operations.
> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>

applied


