From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 1/2]S2io: Change kmalloc+memset to k[zc]alloc
Date: Fri, 31 Aug 2007 09:06:25 -0400
Message-ID: <46D81251.80406@garzik.org>
References: <1187223204.23940.343.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42097 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753470AbXHaNG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:06:26 -0400
In-Reply-To: <1187223204.23940.343.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ramkrishna Vepa wrote:
> - Changed kmalloc+memset to k[zc]alloc as per Mariusz's patch
>   <m.kozlowski@tuxland.pl>
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

ACK patches 1-2, but dropped due to previous dropped patches (presumed 
dependencies)


