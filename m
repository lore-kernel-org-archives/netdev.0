From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3] qla3xxx: cleanup checksum offload code
Date: Wed, 13 Jun 2007 16:04:57 -0400
Message-ID: <46704DE9.9@garzik.org>
References: <20070530212316.407169588@linux-foundation.org> <20070530212512.178720251@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39194 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751618AbXFMUFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 16:05:05 -0400
In-Reply-To: <20070530212512.178720251@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The code for checksum is more complex than needed when dealing with VLAN's;
> the higher layers already pass down the location of the IP header.
> 
> Compile tested only, no hardware available.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied to #upstream (2.6.23)


