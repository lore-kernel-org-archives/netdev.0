From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] myri10ge: Serverworks HT2100 provides aligned PCIe
 completion
Date: Fri, 23 Mar 2007 01:50:34 -0400
Message-ID: <46036AAA.7070807@garzik.org>
References: <45FDA22E.1070805@myri.com> <46017CB8.3060807@myri.com> <46017D3E.3030901@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60484 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753201AbXCWFug (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 01:50:36 -0400
In-Reply-To: <46017D3E.3030901@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> [PATCH 1/4] myri10ge: Serverworks HT2100 provides aligned PCIe completion
> 
> Use the regular firmware on Serverworks HT2100 PCIe ports since this
> chipset provides aligned PCIe completion.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |    8 ++++++++
>  1 file changed, 8 insertions(+)

applied 1-4


