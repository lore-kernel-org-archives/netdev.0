From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] forcedeth fix: take phy out of reset during power up
Date: Wed, 24 Sep 2008 22:15:47 -0400
Message-ID: <48DAF453.9010706@pobox.com>
References: <48D7A3D7.2010602@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55438 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752916AbYIYCP4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 22:15:56 -0400
In-Reply-To: <48D7A3D7.2010602@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> This patch will add the phy reset bit into the power up mask which is 
> used during power up. Certain BIOSes will place the phy in reset and 
> therefore the driver must take the phy out of reset when it loads.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

applied


