From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [3/6] pasemi_mac: set interface speed correctly on XAUI
 ports
Date: Sat, 29 Sep 2007 00:45:54 -0400
Message-ID: <46FDD882.7080302@pobox.com>
References: <20070926212200.GA24168@lixom.net> <20070926212331.GD24168@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48524 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750817AbXI2EqA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 00:46:00 -0400
In-Reply-To: <20070926212331.GD24168@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> pasemi_mac: set interface speed correctly on XAUI ports
> 
> Set interface speed for XAUI to 10G per default, not 1G.
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

applied 3-6 (davem already got 1-2)


