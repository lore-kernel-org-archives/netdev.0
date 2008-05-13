From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] axnet_cs: use netstats in net_device structure
Date: Tue, 13 May 2008 01:37:41 -0400
Message-ID: <48292925.4020204@garzik.org>
References: <4820E7C4.4040404@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dahinds@users.sourceforge.net
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59926 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754833AbYEMFho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 01:37:44 -0400
In-Reply-To: <4820E7C4.4040404@teltonika.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paulius Zaleckas wrote:
> Use net_device_stats from net_device structure instead of local.
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

applied these to net-next...


