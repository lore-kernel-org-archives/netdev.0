From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.21] AT91RM9200 Ethernet: Support additional PHYs
Date: Tue, 08 May 2007 01:30:47 -0400
Message-ID: <46400B07.4050300@garzik.org>
References: <1178176634.14657.153.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Victor <andrew@sanpeople.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54498 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967965AbXEHFau (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:30:50 -0400
In-Reply-To: <1178176634.14657.153.camel@fuzzie.sanpeople.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Victor wrote:
> Add support for a number of new PHY's in the AT91RM9200 Ethernet driver.
> - Teridian 78Q21x3
> - SMSC LAN83C185
>   (Patch from Luca Gamma)
> - National Semiconductor DP83848
>   (Patches from Ivan Kuten & Thomas Foldesi)
> 
> Signed-off-by: Andrew Victor <andrew@sanpeople.com>

applied both patches


