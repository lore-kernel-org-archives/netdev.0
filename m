From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] bmac: add simple ethtool support for network manager
Date: Fri, 31 Aug 2007 09:47:17 -0400
Message-ID: <46D81BE5.4080707@garzik.org>
References: <20070825183259.GA14478@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Olaf Hering <olaf@aepfle.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51170 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965250AbXHaNrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:47:22 -0400
In-Reply-To: <20070825183259.GA14478@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olaf Hering wrote:
> NetworkManager will not start dhcpd on an interface unless it reports
> link-up state via ethtool.
> 
> Signed-off-by: Olaf Hering <olaf@aepfle.de>
> 
> ---
>  drivers/net/bmac.c |   13 +++++++++++++
>  1 file changed, 13 insertions(+)

applied


