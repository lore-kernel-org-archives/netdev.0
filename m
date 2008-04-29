From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] Rename SMSC phy functions to be more generic
Date: Tue, 29 Apr 2008 01:59:10 -0400
Message-ID: <4816B92E.7030702@garzik.org>
References: <1209404206-32551-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53365 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751571AbYD2F7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 01:59:12 -0400
In-Reply-To: <1209404206-32551-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Glendinning wrote:
> Several models of SMSC PHY have the same interrupt status and mask
> registers as the LAN83C185, so these functions can service multiple
> different PHY drivers.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> ---
>  drivers/net/phy/smsc.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)

applied 1-2


