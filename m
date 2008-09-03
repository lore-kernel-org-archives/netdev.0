From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [NET] removed unused #include <version.h>
Date: Wed, 03 Sep 2008 10:24:43 -0400
Message-ID: <48BE9E2B.7010408@pobox.com>
References: <20080817072712.1632.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, netdev@vger.kernel.org
To: Huang Weiyi <weiyi.huang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38946 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686AbYICOYr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:24:47 -0400
In-Reply-To: <20080817072712.1632.WEIYI.HUANG@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Huang Weiyi wrote:
> The drivers below do not use LINUX_VERSION_CODE nor KERNEL_VERSION.
>   drivers/net/myri10ge/myri10ge.c
>   drivers/net/netxen/netxen_nic_ethtool.c
>   drivers/net/tokenring/lanstreamer.c
> 
> This patch removes the said #include <version.h>.
> 
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

applied


