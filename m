From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] 3c505: use netstats in net_device structure
Date: Tue, 29 Apr 2008 01:58:17 -0400
Message-ID: <4816B8F9.60807@garzik.org>
References: <48165D69.30706@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33208 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbYD2F6T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 01:58:19 -0400
In-Reply-To: <48165D69.30706@teltonika.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paulius Zaleckas wrote:
> Use net_device_stats from net_device structure instead of local.
> No need to memset it to 0, because it is allocated by kzalloc.
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

applied this, 3c509 and 3c515


