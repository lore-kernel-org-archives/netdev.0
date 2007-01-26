From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [rft] r8169: merge release 6.001.00 of Realtek's driver - take
 #1
Date: Fri, 26 Jan 2007 03:35:12 -0500
Message-ID: <45B9BD40.4000708@garzik.org>
References: <20070124231719.GA10010@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43655 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030796AbXAZIfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 03:35:14 -0500
In-Reply-To: <20070124231719.GA10010@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Untested, straight from the "release early" dept. You have been warned.
> 
> Realtek's driver restricts itself to 0x8169 and 0x8167.
> It won't be surprising if it breaks on anything else until
> I merge the new 0x8168 and 0x8136 bits.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

FWIW I would like to see if we can train RealTek to directly submit 
kernel patches, and try to mentor them into helping you maintain the 
RealTek stuff.

	Jeff



