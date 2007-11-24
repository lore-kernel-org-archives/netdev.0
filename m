From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 2/2]S2io: Fix to aggregate vlan tagged packets
Date: Fri, 23 Nov 2007 22:05:00 -0500
Message-ID: <474794DC.9000606@garzik.org>
References: <1195509978.1995.46.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39645 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753857AbXKXDFB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 22:05:01 -0500
In-Reply-To: <1195509978.1995.46.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ramkrishna Vepa wrote:
> - Fix to aggregate vlan packets. IP offset is incremented by 
>   4 bytes if the packet contains vlan header.
> 
> Signed-off-by: Santoshkumar Rastapur <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---

ACK but cannot apply due to dropped patches


