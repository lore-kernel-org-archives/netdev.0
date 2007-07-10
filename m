From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] AX88796 network driver
Date: Tue, 10 Jul 2007 12:41:35 -0400
Message-ID: <4693B6BF.3070907@garzik.org>
References: <20070703155309.GA4005@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Dooks <ben@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60141 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753779AbXGJQlh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:41:37 -0400
In-Reply-To: <20070703155309.GA4005@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Dooks wrote:
> Support for the Asix AX88796 network controller, an
> NE2000 compatible 10/100 ethernet device with internal
> PHY.
> 
> The driver supports PHY settings via either ioctl() or
> the ethtool driver ops. 
> 
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>

applied


